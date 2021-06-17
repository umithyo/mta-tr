CREATE TABLE IF NOT EXISTS `fr_housing` (
	`id` INT(11) NOT NULL auto_increment,
	`owner` INT(11) DEFAULT NULL,
	`location` TEXT DEFAULT NULL,
	`creation_time` INT DEFAULT NULL,
	`for_sale` TEXT DEFAULT NULL,
	`sale_price` INT DEFAULT NULL, 
	`saved_by` TEXT DEFAULT NULL,
	`offered` TEXT DEFAULT NULL,
	`bought_date` INT DEFAULT NULL,
	`bought_price` INT DEFAULT NULL,
	`offers` TEXT DEFAULT NULL,
	`name` text,
	primary key (`id`)
)ENGINE=InnoDB; 