-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 24, 2026 at 05:27 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ehr_system`
--

-- --------------------------------------------------------

--
-- Table structure for table `doctors`
--

CREATE TABLE `doctors` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `is_confirmed` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `doctors`
--

INSERT INTO `doctors` (`id`, `username`, `password`, `email`, `is_confirmed`) VALUES
(1, 'admin', 'admin123', 'doctor@test.com', 0),
(6, 'JishaGeo', 'Xyz@4567', 'AbcJ123@gmail.com', 0),
(7, 'ViratKohli', 'Virat@12345', 'Virat123@gmail.com', 0),
(8, 'HelloDr', 'password123', 'hellodr@gmail.com', 0);

-- --------------------------------------------------------

--
-- Table structure for table `patients`
--

CREATE TABLE `patients` (
  `id` int(11) NOT NULL,
  `patient_uid` varchar(50) DEFAULT NULL,
  `doctor_id` int(11) DEFAULT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `weight` float DEFAULT NULL,
  `blood_type` varchar(10) DEFAULT NULL,
  `is_smoker` tinyint(1) DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `image_path` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patients`
--

INSERT INTO `patients` (`id`, `patient_uid`, `doctor_id`, `full_name`, `weight`, `blood_type`, `is_smoker`, `gender`, `dob`, `notes`, `image_path`) VALUES
(9, NULL, 6, 'Ujjwal', 73, 'B+', 0, 'Male', '1997-10-16', 'Typhoid at age of 14.\r\nChickenpox at age 9.', NULL),
(10, 'PAT-2026-9FT8', 1, 'John Doe', 75, 'B+', 0, 'Male', '1997-03-12', 'Thyroid,\r\nPCOD', NULL),
(11, 'PAT-2026-5XVO', 1, 'Thomas', 73, 'O+', 0, 'Male', '1988-03-03', 'High Blood Pressure.\r\nOpen Heart Surgery at age of 52.', NULL),
(12, 'PAT-2026-P3GX', 7, 'Sabina ', 58, 'O+', 0, 'Female', '1967-07-20', 'High Blood Pressure.\r\nDiagnostic laparoscopy was performed after detection of PI in 2017.\r\nFrequent abdominal soreness identified.', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `patient_images`
--

CREATE TABLE `patient_images` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `image_path` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patient_images`
--

INSERT INTO `patient_images` (`id`, `patient_id`, `image_path`) VALUES
(2, 10, '10_Electronic_medical_record3_1.jpg'),
(3, 11, '11_Electronic_medical_record3_1.jpg'),
(5, 12, 'edit_12_download.jpg'),
(6, 12, 'edit_12_Electronic_medical_record3_1.jpg'),
(7, 10, 'edit_10_8124_Screenshot_2025-07-04_205858.png'),
(9, 10, 'edit_10_7713_Screenshot_2026-03-29_155823.png');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `doctors`
--
ALTER TABLE `doctors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `patients`
--
ALTER TABLE `patients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `doctor_id` (`doctor_id`);

--
-- Indexes for table `patient_images`
--
ALTER TABLE `patient_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `doctors`
--
ALTER TABLE `doctors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `patients`
--
ALTER TABLE `patients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `patient_images`
--
ALTER TABLE `patient_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `patients`
--
ALTER TABLE `patients`
  ADD CONSTRAINT `patients_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`);

--
-- Constraints for table `patient_images`
--
ALTER TABLE `patient_images`
  ADD CONSTRAINT `patient_images_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
