import { Readable } from 'stream';
import winston from 'winston';

import {
  ChainSource,
  ChunkDataByAbsoluteOrRelativeOffsetSource,
  TxDataSource,
} from '../types.js';

export class TxChunksDataSource implements TxDataSource {
  private log: winston.Logger;
  private chainSource: ChainSource;
  private chunkSource: ChunkDataByAbsoluteOrRelativeOffsetSource;

  constructor({
    log,
    chainSource,
    chunkSource,
  }: {
    log: winston.Logger;
    chainSource: ChainSource;
    chunkSource: ChunkDataByAbsoluteOrRelativeOffsetSource;
  }) {
    this.log = log.child({ class: 'TxDataChunksRetriever' });
    this.chainSource = chainSource;
    this.chunkSource = chunkSource;
  }

  async getTxData(txId: string): Promise<{ data: Readable; size: number }> {
    this.log.info('Fetching chunk data for tx', { txId });

    try {
      const [txDataRoot, txOffset] = await Promise.all([
        this.chainSource.getTxField(txId, 'data_root'),
        this.chainSource.getTxOffset(txId),
      ]);
      const size = +txOffset.size;
      const offset = +txOffset.offset;
      const startOffset = offset - size + 1;
      let bytes = 0;
      // we lose scope in the readable, so set to internal function
      const getChunkDataByRelativeOrAbsoluteOffset = (
        absoluteOffset: number,
        dataRoot: string,
        relativeOffset: number,
      ) =>
        this.chunkSource.getChunkDataByAbsoluteOrRelativeOffset(
          size,
          absoluteOffset,
          dataRoot,
          relativeOffset,
        );
      let chunkPromise: Promise<Buffer> | undefined =
        getChunkDataByRelativeOrAbsoluteOffset(startOffset, txDataRoot, bytes);
      const data = new Readable({
        autoDestroy: true,
        read: async function () {
          try {
            if (!chunkPromise) {
              this.push(null);
              return;
            }

            const chunk = await chunkPromise;
            this.push(chunk);
            bytes += chunk.length;

            if (bytes < size) {
              chunkPromise = getChunkDataByRelativeOrAbsoluteOffset(
                startOffset + bytes,
                txDataRoot,
                bytes,
              );
            } else {
              chunkPromise = undefined;
            }
          } catch (error: any) {
            this.destroy(error);
          }
        },
      });
      return {
        data,
        size,
      };
    } catch (error: any) {
      this.log.error('Failed to retrieve transaction data:', {
        txId,
        messag: error.message,
        stack: error.stack,
      });
      throw error;
    }
  }
}
