INSERT INTO `ohrm_oauth2_access_token` (`access_token`, `client_id`, `user_id`, `expiry_date_time_utc`, `revoked`) VALUES
('0e5f3284f2df8fdcc81f601080710e1013afe010ad674e7f4898d6a1ffdd519bd42f1165e501079b', 1, 1, '2099-12-31 11:59:59', 0);

UPDATE `hs_hr_config` SET `value` = 'aJmvC3dsidQB6xhfJN7GzAY+Gj/Ofl27RPardtqK+gs=' WHERE `hs_hr_config`.`name` = 'oauth.encryption_key';

UPDATE `hs_hr_config` SET `value` = 'AAs8cg3JauC6nUqfF8kDnLZ6Uun2q5dHQ9zkLtS7MAM=' WHERE `hs_hr_config`.`name` = 'oauth.token_encryption_key';