-- phpMyAdmin SQL Dump
-- version 2.9.1.1-Debian-6
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Feb 07, 2008 at 03:44 PM
-- Server version: 5.0.32
-- PHP Version: 5.2.0-8+etch9
-- 
-- Database: `rg3_redir`
-- 

-- --------------------------------------------------------

-- 
-- Table structure for table `dominios`
-- 

CREATE TABLE `dominios` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `nome` varchar(256) collate latin1_general_ci NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `nome` (`nome`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `grupos`
-- 

CREATE TABLE `grupos` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `nome` varchar(256) collate latin1_general_ci NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `redirmail`
-- 

CREATE TABLE `redirmail` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `uid` int(10) unsigned NOT NULL,
  `id_dominio` int(10) unsigned NOT NULL,
  `de` varchar(256) collate latin1_general_ci NOT NULL,
  `para` varchar(256) collate latin1_general_ci NOT NULL,
  `data_criacao` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `data_umod` timestamp NULL default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `id_dominio` (`id_dominio`,`de`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `redirurl`
-- 

CREATE TABLE `redirurl` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `uid` int(10) unsigned NOT NULL,
  `id_dominio` int(10) unsigned NOT NULL,
  `de` varchar(256) collate latin1_general_ci NOT NULL,
  `para` varchar(256) collate latin1_general_ci NOT NULL,
  `acessos` int(10) unsigned NOT NULL default '0',
  `data_criacao` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `data_umod` timestamp NULL default NULL,
  `titulo` varchar(256) collate latin1_general_ci default NULL,
  `descricao` varchar(256) collate latin1_general_ci default NULL,
  `keywords` varchar(256) collate latin1_general_ci default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `id_dominio` (`id_dominio`,`de`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `usuarios`
-- 

CREATE TABLE `usuarios` (
  `uid` int(10) unsigned NOT NULL auto_increment,
  `id_grupo` int(10) unsigned NOT NULL,
  `login` varchar(32) collate latin1_general_ci NOT NULL,
  `senha` char(32) character set latin1 collate latin1_general_cs NOT NULL,
  `email` char(32) collate latin1_general_ci NOT NULL,
  `data_cadastro` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `data_uacesso` timestamp NULL default NULL,
  `ip_cadastro` char(34) collate latin1_general_ci NOT NULL default '0.0.0.0',
  `ip_uacesso` char(34) collate latin1_general_ci default NULL,
  PRIMARY KEY  (`uid`),
  UNIQUE KEY `login` (`login`),
  UNIQUE KEY `email` (`email`),
  KEY `id_grupo` (`id_grupo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci AUTO_INCREMENT=3 ;

-- 
-- Constraints for dumped tables
-- 

-- 
-- Constraints for table `redirmail`
-- 
ALTER TABLE `redirmail`
  ADD CONSTRAINT `redirmail_ibfk_1` FOREIGN KEY (`uid`) REFERENCES `usuarios` (`uid`),
  ADD CONSTRAINT `redirmail_ibfk_2` FOREIGN KEY (`id_dominio`) REFERENCES `dominios` (`id`);

-- 
-- Constraints for table `redirurl`
-- 
ALTER TABLE `redirurl`
  ADD CONSTRAINT `redirurl_ibfk_3` FOREIGN KEY (`uid`) REFERENCES `usuarios` (`uid`),
  ADD CONSTRAINT `redirurl_ibfk_4` FOREIGN KEY (`id_dominio`) REFERENCES `dominios` (`id`);

-- 
-- Constraints for table `usuarios`
-- 
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`id_grupo`) REFERENCES `grupos` (`id`);
