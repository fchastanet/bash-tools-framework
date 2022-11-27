-- MySQL dump 10.13  Distrib 8.0.27, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: skills
-- ------------------------------------------------------
-- Server version	8.0.16

--
-- Table structure for table `core_customer`
--

CREATE TABLE `core_customer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `instance_name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `instance_name` (`instance_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_learner`
--

CREATE TABLE `core_learner` (
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `external_id` varchar(255) NOT NULL,
  `customer_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_learner_by_customer` (`external_id`,`customer_id`),
  KEY `core_learner_customer_id_6d356da8_fk_core_customer_id` (`customer_id`),
  CONSTRAINT `core_learner_customer_id_6d356da8_fk_core_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `core_customer` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_learnerskill`
--

CREATE TABLE `core_learnerskill` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `level` double NOT NULL,
  `interest` double NOT NULL,
  `learner_id` int(10) unsigned NOT NULL,
  `skill_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `core_learnerskill_learner_id_684f904f_fk_core_learner_id` (`learner_id`),
  KEY `core_learnerskill_skill_id_fa4d99ac_fk_core_skill_id` (`skill_id`),
  CONSTRAINT `core_learnerskill_learner_id_684f904f_fk_core_learner_id` FOREIGN KEY (`learner_id`) REFERENCES `core_learner` (`id`),
  CONSTRAINT `core_learnerskill_skill_id_fa4d99ac_fk_core_skill_id` FOREIGN KEY (`skill_id`) REFERENCES `core_skill` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=415 DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_skill`
--

CREATE TABLE `core_skill` (
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `translations` json NOT NULL,
  `mapped_skill_id` int(10) unsigned DEFAULT NULL,
  `internal_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `core_skill_internal_id_8bcc4534_uniq` (`internal_id`),
  KEY `core_skill_mapped_skill_id_7b712770_fk_core_skill_id` (`mapped_skill_id`),
  CONSTRAINT `core_skill_mapped_skill_id_7b712770_fk_core_skill_id` FOREIGN KEY (`mapped_skill_id`) REFERENCES `core_skill` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=190 DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_trainingcourse`
--

CREATE TABLE `core_trainingcourse` (
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `external_id` int(10) unsigned NOT NULL,
  `customer_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_training_by_customer` (`external_id`,`customer_id`),
  KEY `core_trainingcourse_customer_id_0137ae93_fk_core_customer_id` (`customer_id`),
  CONSTRAINT `core_trainingcourse_customer_id_0137ae93_fk_core_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `core_customer` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_trainingcourseskill`
--

CREATE TABLE `core_trainingcourseskill` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `relevance` double NOT NULL,
  `skill_id` int(10) unsigned NOT NULL,
  `training_course_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `core_trainingcourseskill_skill_id_1d096250_fk_core_skill_id` (`skill_id`),
  KEY `core_trainingcourses_training_course_id_56f0012b_fk_core_trai` (`training_course_id`),
  CONSTRAINT `core_trainingcourses_training_course_id_56f0012b_fk_core_trai` FOREIGN KEY (`training_course_id`) REFERENCES `core_trainingcourse` (`id`),
  CONSTRAINT `core_trainingcourseskill_skill_id_1d096250_fk_core_skill_id` FOREIGN KEY (`skill_id`) REFERENCES `core_skill` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8;


-- Dump completed on 2021-11-08 21:28:48
