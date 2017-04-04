DROP TABLE IF EXISTS `quiz`;
CREATE TABLE `quiz` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
  `quizId` VARCHAR(255), 
  `quizTitle` VARCHAR(255), 
  `userId` VARCHAR(255), 
  `userMail` VARCHAR(255), 
  `userScore` FLOAT, 
  `totalScore` FLOAT, 
  `passScore` FLOAT, 
  `passState` BOOL, 
  `Result` mediumtext, 
  `regMail` VARCHAR(255), 
  `regCode` VARCHAR(255), 
  `addDate` TIMESTAMP
);

DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
  `userId` VARCHAR(255), 
  `userPwd` VARCHAR(255), 
  `sys` BOOL DEFAULT 0, 
  `addDate` TIMESTAMP
);

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
  `userId` VARCHAR(255), 
  `userPwd` VARCHAR(255), 
  `userMail` VARCHAR(255), 
  `admin` VARCHAR(255), 
  `inUse` BOOL DEFAULT 1, 
  `addDate` TIMESTAMP
);

INSERT INTO `admin` VALUES (1, 'admin', '123456', 1, NOW());