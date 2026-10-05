CREATE TABLE `connections` (
	`user_id` text NOT NULL,
	`provider` text NOT NULL,
	`encrypted` text NOT NULL,
	`expires` integer NOT NULL,
	`updated` integer NOT NULL,
	`last_sync` integer,
	PRIMARY KEY(`user_id`, `provider`),
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE TABLE `favorites` (
	`user_id` text NOT NULL,
	`track_key` text NOT NULL,
	`track` text NOT NULL,
	`created` integer NOT NULL,
	PRIMARY KEY(`user_id`, `track_key`),
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE TABLE `invites` (
	`hash` text PRIMARY KEY NOT NULL,
	`room_id` text NOT NULL,
	`expires` integer NOT NULL,
	FOREIGN KEY (`room_id`) REFERENCES `rooms`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `invites_room_idx` ON `invites` (`room_id`);--> statement-breakpoint
CREATE TABLE `limits` (
	`key` text PRIMARY KEY NOT NULL,
	`count` integer NOT NULL,
	`expires` integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE `listens` (
	`user_id` text NOT NULL,
	`track_key` text NOT NULL,
	`provider` text NOT NULL,
	`track` text NOT NULL,
	`played_at` integer,
	`synced_at` integer NOT NULL,
	PRIMARY KEY(`user_id`, `track_key`),
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `listens_user_time_idx` ON `listens` (`user_id`,`synced_at`);--> statement-breakpoint
CREATE TABLE `members` (
	`user_id` text PRIMARY KEY NOT NULL,
	`room_id` text NOT NULL,
	`joined` integer NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`room_id`) REFERENCES `rooms`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `members_room_idx` ON `members` (`room_id`);--> statement-breakpoint
CREATE TABLE `oauth` (
	`hash` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`verifier` text NOT NULL,
	`expires` integer NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE TABLE `rooms` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`owner` text NOT NULL,
	`created` integer NOT NULL,
	FOREIGN KEY (`owner`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE TABLE `shares` (
	`id` text PRIMARY KEY NOT NULL,
	`room_id` text NOT NULL,
	`user_id` text NOT NULL,
	`track` text NOT NULL,
	`note` text NOT NULL,
	`created` integer NOT NULL,
	FOREIGN KEY (`room_id`) REFERENCES `rooms`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `shares_room_created_idx` ON `shares` (`room_id`,`created`);--> statement-breakpoint
CREATE TABLE `users` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`platform` text DEFAULT 'spotify' NOT NULL,
	`share_history` integer DEFAULT 0 NOT NULL,
	`created` integer NOT NULL
);
