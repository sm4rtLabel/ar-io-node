-- insertOrIgnoreWallet
INSERT INTO wallets (address, public_modulus)
VALUES (@address, @public_modulus)
ON CONFLICT DO NOTHING

-- insertOrIgnoreTagName
INSERT INTO tag_names (hash, name)
VALUES (@hash, @name)
ON CONFLICT DO NOTHING

-- insertOrIgnoreTagValue
INSERT INTO tag_values (hash, value)
VALUES (@hash, @value)
ON CONFLICT DO NOTHING

-- insertOrIgnoreNewBlock
INSERT INTO new_blocks (
  indep_hash, height, previous_block, nonce, hash,
  block_timestamp, diff,
  cumulative_diff, last_retarget,
  reward_addr, reward_pool,
  block_size, weave_size,
  usd_to_ar_rate_dividend,
  usd_to_ar_rate_divisor,
  scheduled_usd_to_ar_rate_dividend,
  scheduled_usd_to_ar_rate_divisor,
  hash_list_merkle, wallet_list, tx_root,
  tx_count, missing_tx_count
) VALUES (
  @indep_hash, @height, @previous_block, @nonce, @hash,
  CAST(@block_timestamp AS INTEGER), @diff,
  @cumulative_diff, CAST(@last_retarget AS INTEGER),
  @reward_addr, CAST(@reward_pool AS INTEGER),
  CAST(@block_size AS INTEGER), CAST(@weave_size AS INTEGER),
  CAST(@usd_to_ar_rate_dividend AS INTEGER),
  CAST(@usd_to_ar_rate_divisor AS INTEGER),
  CAST(@scheduled_usd_to_ar_rate_dividend AS INTEGER),
  CAST(@scheduled_usd_to_ar_rate_divisor AS INTEGER),
  @hash_list_merkle, @wallet_list, @tx_root,
  @tx_count, @missing_tx_count
) ON CONFLICT DO NOTHING

-- insertOrIgnoreNewBlockHeight
INSERT INTO new_block_heights (
  height, block_indep_hash
) VALUES (
  @height, @block_indep_hash
) ON CONFLICT DO NOTHING

-- insertOrIgnoreNewBlockTransaction
INSERT INTO new_block_transactions (
  block_indep_hash, transaction_id, block_transaction_index
) VALUES (
  @block_indep_hash, @transaction_id, @block_transaction_index
) ON CONFLICT DO NOTHING

-- insertOrIgnoreNewTransactionTag
INSERT INTO new_transaction_tags (
  tag_name_hash, tag_value_hash,
  transaction_id, transaction_tag_index
) VALUES (
  @tag_name_hash, @tag_value_hash,
  @transaction_id, @transaction_tag_index
) ON CONFLICT DO NOTHING

-- insertOrIgnoreNewTransaction
INSERT INTO new_transactions (
  id, signature, format, last_tx, owner_address,
  target, quantity, reward, data_size, data_root,
  tag_count, content_type, created_at
) VALUES (
  @id, @signature, @format, @last_tx, @owner_address,
  @target, @quantity, @reward, @data_size, @data_root,
  @tag_count, @content_type, @created_at
) ON CONFLICT DO NOTHING

-- insertOrIgnoreMissingTransaction
INSERT INTO missing_transactions (
  block_indep_hash, transaction_id, height
) VALUES (
  @block_indep_hash, @transaction_id, @height
) ON CONFLICT DO NOTHING