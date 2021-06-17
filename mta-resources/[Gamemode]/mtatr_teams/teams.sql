CREATE TABLE IF NOT EXISTS `fr_groups` (
	`id` INT(11) NOT NULL auto_increment,
	`name` TEXT DEFAULT NULL,
	/* `tag` TEXT DEFAULT NULL,  */
	`colour` TEXT DEFAULT NULL,
	`creation_time` INT (11) DEFAULT NULL,
	`info` TEXT DEFAULT NULL,
	`shoutbox` TEXT DEFAULT NULL,
	PRIMARY KEY (`id`)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `fr_group_members` (
	`id` INT (11) NOT NULL auto_increment,
	`group_id` INT DEFAULT NULL,
	`user_id` INT DEFAULT NULL,
	`join_time` INT (11) DEFAULT NULL,
	`rank_id` TEXT DEFAULT NULL,
	PRIMARY KEY (`id`)
)ENGINE=InnoDB;