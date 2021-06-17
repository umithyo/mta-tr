CREATE TABLE IF NOT EXISTS `userinfo` (
	`id` INT(11) NOT NULL auto_increment,
	`mail` TEXT DEFAULT NULL, 
	`password` TEXT DEFAULT NULL,
	`serial` TEXT DEFAULT NULL, 
	`registerdate` TEXT DEFAULT NULL, 
	`lastseen` TEXT DEFAULT NULL,
	primary key (`id`)
)ENGINE=InnoDB; 

CREATE TABLE IF NOT EXISTS `fr_stats` (
	`id` INT (11) NOT NULL auto_increment, 
	`mail` TEXT DEFAULT NULL,
	`money` INT DEFAULT NULL,
	`usercolour` TEXT DEFAULT NULL,
	`characters` TEXT DEFAULT NULL,
	`kills` INT DEFAULT NULL,
	`deaths` INT DEFAULT NULL,
	`dmg` FLOAT DEFAULT NULL,
	`dm.kills` INT DEFAULT NULL,
	`dm.deaths` INT DEFAULT NULL,
	`dm.dmg` FLOAT DEFAULT NULL,
	`assists` INT DEFAULT NULL,
	`lastseen` TEXT DEFAULT NULL,
	primary key (`id`)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `addresslist` (
	`id` INT (11) NOT NULL auto_increment,
	`user_id` INT DEFAULT NULL,
	`serial` TEXT DEFAULT NULL,
	`address` TEXT DEFAULT NULL,
	primary key (`id`)
)ENGINE=InnoDB;