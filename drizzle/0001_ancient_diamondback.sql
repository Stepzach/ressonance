CREATE INDEX `invites_expiry_idx` ON `invites` (`expires`);--> statement-breakpoint
CREATE INDEX `limits_expiry_idx` ON `limits` (`expires`);--> statement-breakpoint
CREATE INDEX `listens_retention_idx` ON `listens` (`synced_at`);--> statement-breakpoint
CREATE INDEX `oauth_expiry_idx` ON `oauth` (`expires`);
