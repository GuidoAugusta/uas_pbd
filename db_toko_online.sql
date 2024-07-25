-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 25, 2024 at 12:08 PM
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
-- Database: `db_toko_online`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CountProsesOrders` ()   BEGIN
    DECLARE proses_orders INT;

    SELECT COUNT(*) INTO proses_orders
    FROM pesanan
    WHERE status = 'Diproses';

    CASE
        WHEN proses_orders = 0 THEN
            SELECT 'Tidak ada pesanan yang diproses' AS Message;
        ELSE
            SELECT proses_orders AS ProsesOrders;
    END CASE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TotalSalesByPeriod` (IN `start_date` DATE, IN `end_date` DATE)   BEGIN
    DECLARE total_sales DECIMAL(10, 2);

    SELECT SUM(total_harga) INTO total_sales
    FROM pesanan
    WHERE tanggal_pesanan BETWEEN start_date AND end_date;

    CASE
        WHEN total_sales IS NULL THEN
            SELECT 'Tidak ada penjualan pada periode tersebut' AS Message;
        ELSE
            SELECT CONCAT('Total penjualan adalah: ', total_sales) AS TotalSales;
    END CASE;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `TotalProducts` () RETURNS INT(11)  BEGIN
    DECLARE total INT;

    SELECT COUNT(*) INTO total 
    FROM produk;

    RETURN total;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `TotalRevenueByPeriod` (`start_date` DATE, `end_date` DATE) RETURNS DECIMAL(10,2)  BEGIN
    DECLARE total_revenue DECIMAL(10, 2);

    SELECT SUM(total_harga) INTO total_revenue
    FROM pesanan
    WHERE tanggal_pesanan BETWEEN start_date AND end_date;

    IF total_revenue IS NULL THEN
        SET total_revenue = 0.00;
    END IF;

    RETURN total_revenue;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `detail_pesanan`
--

CREATE TABLE `detail_pesanan` (
  `id_pesanan` int(11) NOT NULL,
  `id_produk` int(11) NOT NULL,
  `jumlah` int(11) DEFAULT NULL,
  `harga` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detail_pesanan`
--

INSERT INTO `detail_pesanan` (`id_pesanan`, `id_produk`, `jumlah`, `harga`) VALUES
(1, 1, 1, 15000000.00),
(1, 3, 1, 500000.00),
(2, 2, 2, 7000000.00),
(3, 2, 1, 7000000.00),
(3, 3, 2, 500000.00),
(4, 4, 1, 12000000.00),
(5, 5, 3, 8000000.00),
(6, 1, 2, 15000000.00),
(6, 2, 3, 7000000.00);

--
-- Triggers `detail_pesanan`
--
DELIMITER $$
CREATE TRIGGER `UpdateTotalHargaPesanan` AFTER INSERT ON `detail_pesanan` FOR EACH ROW BEGIN
    UPDATE pesanan
    SET total_harga = HitungTotalHargaPesanan(NEW.id_pesanan)
    WHERE id_pesanan = NEW.id_pesanan;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `UpdateTotalHargaPesananOnUpdate` AFTER UPDATE ON `detail_pesanan` FOR EACH ROW BEGIN
    UPDATE pesanan
    SET total_harga = HitungTotalHargaPesanan(NEW.id_pesanan)
    WHERE id_pesanan = NEW.id_pesanan;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `detail_produk`
--

CREATE TABLE `detail_produk` (
  `id_produk` int(11) NOT NULL,
  `berat` decimal(10,2) DEFAULT NULL,
  `dimensi` varchar(50) DEFAULT NULL,
  `deskripsi` text DEFAULT NULL,
  `warna` varchar(30) DEFAULT NULL,
  `stok` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detail_produk`
--

INSERT INTO `detail_produk` (`id_produk`, `berat`, `dimensi`, `deskripsi`, `warna`, `stok`) VALUES
(1, 2.50, '35x24x2 cm', 'Laptop dengan prosesor Intel i7, RAM 16GB, SSD 512GB', 'Hitam', 50),
(2, 0.20, '15x7x0.8 cm', 'Smartphone dengan layar 6.5 inci, RAM 8GB, ROM 128GB', 'Putih', 150),
(3, 0.30, '20x18x5 cm', 'Headphone nirkabel dengan noise cancellation', 'Biru', 100),
(4, 10.00, '110x70x10 cm', 'TV 55 inci dengan resolusi 4K UHD', 'Hitam', 30),
(5, 50.00, '70x60x180 cm', 'Kulkas dua pintu dengan kapasitas 300 liter', 'Silver', 20);

-- --------------------------------------------------------

--
-- Stand-in structure for view `horizontal_view`
-- (See below for the actual view)
--
CREATE TABLE `horizontal_view` (
`id_produk` int(11)
,`berat` decimal(10,2)
,`dimensi` varchar(50)
,`deskripsi` text
,`nama_kategori` varchar(50)
);

-- --------------------------------------------------------

--
-- Table structure for table `kategori_produk`
--

CREATE TABLE `kategori_produk` (
  `id_kategori` int(11) NOT NULL,
  `nama_kategori` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kategori_produk`
--

INSERT INTO `kategori_produk` (`id_kategori`, `nama_kategori`) VALUES
(1, 'Elektronik'),
(2, 'Smartphone'),
(3, 'Aksesoris'),
(4, 'Televisi'),
(5, 'Peralatan Rumah Tangga');

-- --------------------------------------------------------

--
-- Table structure for table `log_perubahan`
--

CREATE TABLE `log_perubahan` (
  `id_log` int(11) NOT NULL,
  `nama_tabel` varchar(100) DEFAULT NULL,
  `operasi` varchar(10) DEFAULT NULL,
  `waktu` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_lama` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data_lama`)),
  `data_baru` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data_baru`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_perubahan`
--

INSERT INTO `log_perubahan` (`id_log`, `nama_tabel`, `operasi`, `waktu`, `data_lama`, `data_baru`) VALUES
(1, 'produk', 'INSERT', '2024-07-25 08:06:41', NULL, '{\"id_produk\": 6, \"nama_produk\": \"Microwave\", \"harga\": 1200000.00}'),
(2, 'produk', 'UPDATE', '2024-07-25 08:09:20', '{\"id_produk\": 6, \"nama_produk\": \"Microwave\", \"harga\": 1200000.00}', '{\"id_produk\": 6, \"nama_produk\": \"Microwave\", \"harga\": 1250000.00}'),
(3, 'produk', 'DELETE', '2024-07-25 08:11:01', '{\"id_produk\": 6, \"nama_produk\": \"Microwave\", \"harga\": 1250000.00}', NULL),
(4, 'pesanan', 'INSERT', '2024-07-25 08:18:22', NULL, '{\"id_pesanan\": 7, \"id_pengguna\": 3, \"tanggal_pesanan\": \"0000-00-00\", \"status\": \"Diproses\", \"total_harga\": 70000.00}'),
(5, 'pesanan', 'UPDATE', '2024-07-25 08:23:45', '{\"id_pesanan\": 7, \"id_pengguna\": 3, \"tanggal_pesanan\": \"0000-00-00\", \"status\": \"Diproses\", \"total_harga\": 70000.00}', '{\"id_pesanan\": 7, \"id_pengguna\": 3, \"tanggal_pesanan\": \"2024-07-25\", \"status\": \"Diproses\", \"total_harga\": 70000.00}'),
(6, 'pesanan', 'DELETE', '2024-07-25 08:25:03', '{\"id_pesanan\": 7, \"id_pengguna\": 3, \"tanggal_pesanan\": \"2024-07-25\", \"status\": \"Diproses\", \"total_harga\": 70000.00}', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pengguna`
--

CREATE TABLE `pengguna` (
  `id_pengguna` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pengguna`
--

INSERT INTO `pengguna` (`id_pengguna`, `nama`) VALUES
(1, 'Ahmad Faisal'),
(2, 'Budi Santoso'),
(3, 'Citra Dewi'),
(4, 'Dewi Lestari'),
(5, 'Eka Putra');

-- --------------------------------------------------------

--
-- Table structure for table `pesanan`
--

CREATE TABLE `pesanan` (
  `id_pesanan` int(11) NOT NULL,
  `id_pengguna` int(11) DEFAULT NULL,
  `tanggal_pesanan` date DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `total_harga` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pesanan`
--

INSERT INTO `pesanan` (`id_pesanan`, `id_pengguna`, `tanggal_pesanan`, `status`, `total_harga`) VALUES
(1, 1, '2024-07-01', 'Diproses', 15500000.00),
(2, 2, '2024-07-02', 'Dikirim', 14000000.00),
(3, 3, '2024-07-03', 'Selesai', 8000000.00),
(4, 4, '2024-07-04', 'Diproses', 12000000.00),
(5, 5, '2024-07-05', 'Dibatalkan', 8000000.00),
(6, 4, '2024-07-08', 'Diproses', 51000000.00);

--
-- Triggers `pesanan`
--
DELIMITER $$
CREATE TRIGGER `after_delete_pesanan` AFTER DELETE ON `pesanan` FOR EACH ROW BEGIN
    INSERT INTO log_perubahan (nama_tabel, operasi, data_lama)
    VALUES ('pesanan', 'DELETE', JSON_OBJECT('id_pesanan', OLD.id_pesanan, 'id_pengguna', OLD.id_pengguna, 'tanggal_pesanan', OLD.tanggal_pesanan, 'status', OLD.status, 'total_harga', OLD.total_harga));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_pesanan` AFTER INSERT ON `pesanan` FOR EACH ROW BEGIN
    INSERT INTO log_perubahan (nama_tabel, operasi, data_baru)
    VALUES ('pesanan', 'INSERT', JSON_OBJECT('id_pesanan', NEW.id_pesanan, 'id_pengguna', NEW.id_pengguna, 'tanggal_pesanan', NEW.tanggal_pesanan, 'status', NEW.status, 'total_harga', NEW.total_harga));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_update_pesanan` AFTER UPDATE ON `pesanan` FOR EACH ROW BEGIN
    INSERT INTO log_perubahan (nama_tabel, operasi, data_lama, data_baru)
    VALUES ('pesanan', 'UPDATE', JSON_OBJECT('id_pesanan', OLD.id_pesanan, 'id_pengguna', OLD.id_pengguna, 'tanggal_pesanan', OLD.tanggal_pesanan, 'status', OLD.status, 'total_harga', OLD.total_harga),
            JSON_OBJECT('id_pesanan', NEW.id_pesanan, 'id_pengguna', NEW.id_pengguna, 'tanggal_pesanan', NEW.tanggal_pesanan, 'status', NEW.status, 'total_harga', NEW.total_harga));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `produk`
--

CREATE TABLE `produk` (
  `id_produk` int(11) NOT NULL,
  `nama_produk` varchar(100) DEFAULT NULL,
  `harga` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `produk`
--

INSERT INTO `produk` (`id_produk`, `nama_produk`, `harga`) VALUES
(1, 'Laptop XYZ', 15000000.00),
(2, 'Smartphone ABC', 7000000.00),
(3, 'Headphone DEF', 500000.00),
(4, 'TV GHI', 12000000.00),
(5, 'Kulkas JKL', 8000000.00);

--
-- Triggers `produk`
--
DELIMITER $$
CREATE TRIGGER `before_delete_produk` BEFORE DELETE ON `produk` FOR EACH ROW BEGIN
    INSERT INTO log_perubahan (nama_tabel, operasi, data_lama)
    VALUES ('produk', 'DELETE', JSON_OBJECT('id_produk', OLD.id_produk, 'nama_produk', OLD.nama_produk, 'harga', OLD.harga));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_produk` BEFORE INSERT ON `produk` FOR EACH ROW BEGIN
    INSERT INTO log_perubahan (nama_tabel, operasi, data_baru)
    VALUES ('produk', 'INSERT', JSON_OBJECT('id_produk', NEW.id_produk, 'nama_produk', NEW.nama_produk, 'harga', NEW.harga));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_produk` BEFORE UPDATE ON `produk` FOR EACH ROW BEGIN
    INSERT INTO log_perubahan (nama_tabel, operasi, data_lama, data_baru)
    VALUES ('produk', 'UPDATE', JSON_OBJECT('id_produk', OLD.id_produk, 'nama_produk', OLD.nama_produk, 'harga', OLD.harga),
            JSON_OBJECT('id_produk', NEW.id_produk, 'nama_produk', NEW.nama_produk, 'harga', NEW.harga));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `produk_kategori`
--

CREATE TABLE `produk_kategori` (
  `id_produk` int(11) NOT NULL,
  `id_kategori` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `produk_kategori`
--

INSERT INTO `produk_kategori` (`id_produk`, `id_kategori`) VALUES
(1, 1),
(1, 3),
(2, 1),
(2, 2),
(3, 1),
(3, 3),
(4, 4),
(5, 5);

-- --------------------------------------------------------

--
-- Table structure for table `profil_pengguna`
--

CREATE TABLE `profil_pengguna` (
  `id_pengguna` int(11) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `no_telepon` varchar(15) DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `jenis_kelamin` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `profil_pengguna`
--

INSERT INTO `profil_pengguna` (`id_pengguna`, `email`, `password`, `alamat`, `no_telepon`, `tanggal_lahir`, `jenis_kelamin`) VALUES
(1, 'ahmad.faisal@example.com', 'encryptedpassword1', 'Jl. Merdeka No. 10, Jakarta', '081234567890', '1990-01-01', 'Laki-laki'),
(2, 'budi.santoso@example.com', 'encryptedpassword2', 'Jl. Sudirman No. 20, Bandung', '081298765432', '1985-05-15', 'Laki-laki'),
(3, 'citra.dewi@example.com', 'encryptedpassword3', 'Jl. Thamrin No. 30, Surabaya', '082134567891', '1992-12-12', 'Perempuan'),
(4, 'dewi.lestari@example.com', 'encryptedpassword4', 'Jl. Kebon Jeruk No. 40, Medan', '081234569876', '1988-07-07', 'Perempuan'),
(5, 'eka.putra@example.com', 'encryptedpassword5', 'Jl. Diponegoro No. 50, Yogyakarta', '081223344556', '1995-03-25', 'Laki-laki');

-- --------------------------------------------------------

--
-- Table structure for table `review`
--

CREATE TABLE `review` (
  `id_review` int(11) NOT NULL,
  `id_pengguna` int(11) DEFAULT NULL,
  `id_produk` int(11) DEFAULT NULL,
  `bintang` int(11) DEFAULT NULL,
  `komentar` text DEFAULT NULL,
  `tanggal_review` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `review`
--

INSERT INTO `review` (`id_review`, `id_pengguna`, `id_produk`, `bintang`, `komentar`, `tanggal_review`) VALUES
(1, 1, 1, 4, 'Produk sangat baik, tetapi pengirimannya agak lambat.', '2024-07-03'),
(2, 2, 2, 5, 'Sangat puas dengan kualitas produk ini!', '2024-07-04'),
(3, 3, 3, 3, 'Kualitasnya standar, harga sebanding.', '2024-07-05'),
(4, 4, 4, 2, 'Kualitas produk mengecewakan, layanan pelanggan kurang responsif.', '2024-07-06'),
(5, 5, 5, 4, 'Produk ini sangat berguna untuk kebutuhan sehari-hari.', '2024-07-07');

-- --------------------------------------------------------

--
-- Stand-in structure for view `vertical_view`
-- (See below for the actual view)
--
CREATE TABLE `vertical_view` (
`id_pengguna` int(11)
,`nama` varchar(100)
,`email` varchar(100)
,`password` varchar(255)
,`alamat` text
,`no_telepon` varchar(15)
,`tanggal_lahir` date
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `viewdetailpesanan`
-- (See below for the actual view)
--
CREATE TABLE `viewdetailpesanan` (
`id_pesanan` int(11)
,`tanggal_pesanan` date
,`status` varchar(50)
,`id_produk` int(11)
,`nama_produk` varchar(100)
,`jumlah` int(11)
,`harga` decimal(10,2)
,`nama_pengguna` varchar(100)
,`email` varchar(100)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_inside_view`
-- (See below for the actual view)
--
CREATE TABLE `view_inside_view` (
`id_produk` int(11)
,`nama_kategori` varchar(50)
,`email` varchar(100)
);

-- --------------------------------------------------------

--
-- Structure for view `horizontal_view`
--
DROP TABLE IF EXISTS `horizontal_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `horizontal_view`  AS SELECT `dp`.`id_produk` AS `id_produk`, `dp`.`berat` AS `berat`, `dp`.`dimensi` AS `dimensi`, `dp`.`deskripsi` AS `deskripsi`, `kp`.`nama_kategori` AS `nama_kategori` FROM (`detail_produk` `dp` join `kategori_produk` `kp` on(`dp`.`id_produk` = `kp`.`id_kategori`)) ;

-- --------------------------------------------------------

--
-- Structure for view `vertical_view`
--
DROP TABLE IF EXISTS `vertical_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vertical_view`  AS SELECT `p`.`id_pengguna` AS `id_pengguna`, `p`.`nama` AS `nama`, `pp`.`email` AS `email`, `pp`.`password` AS `password`, `pp`.`alamat` AS `alamat`, `pp`.`no_telepon` AS `no_telepon`, `pp`.`tanggal_lahir` AS `tanggal_lahir` FROM (`pengguna` `p` join `profil_pengguna` `pp` on(`p`.`id_pengguna` = `pp`.`id_pengguna`)) WHERE `pp`.`jenis_kelamin` = 'Laki-laki' ;

-- --------------------------------------------------------

--
-- Structure for view `viewdetailpesanan`
--
DROP TABLE IF EXISTS `viewdetailpesanan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `viewdetailpesanan`  AS SELECT `p`.`id_pesanan` AS `id_pesanan`, `p`.`tanggal_pesanan` AS `tanggal_pesanan`, `p`.`status` AS `status`, `dp`.`id_produk` AS `id_produk`, `pr`.`nama_produk` AS `nama_produk`, `dp`.`jumlah` AS `jumlah`, `dp`.`harga` AS `harga`, `u`.`nama` AS `nama_pengguna`, `pp`.`email` AS `email` FROM ((((`pesanan` `p` join `detail_pesanan` `dp` on(`p`.`id_pesanan` = `dp`.`id_pesanan`)) join `produk` `pr` on(`dp`.`id_produk` = `pr`.`id_produk`)) join `pengguna` `u` on(`p`.`id_pengguna` = `u`.`id_pengguna`)) join `profil_pengguna` `pp` on(`u`.`id_pengguna` = `pp`.`id_pengguna`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_inside_view`
--
DROP TABLE IF EXISTS `view_inside_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_inside_view`  AS SELECT `hv`.`id_produk` AS `id_produk`, `hv`.`nama_kategori` AS `nama_kategori`, `vv`.`email` AS `email` FROM (`horizontal_view` `hv` join `vertical_view` `vv` on(`hv`.`id_produk` = `vv`.`id_pengguna`))WITH LOCAL CHECK OPTION  ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `detail_pesanan`
--
ALTER TABLE `detail_pesanan`
  ADD PRIMARY KEY (`id_pesanan`,`id_produk`),
  ADD KEY `id_produk` (`id_produk`);

--
-- Indexes for table `detail_produk`
--
ALTER TABLE `detail_produk`
  ADD PRIMARY KEY (`id_produk`),
  ADD KEY `idx_berat_dimensi` (`berat`,`dimensi`);

--
-- Indexes for table `kategori_produk`
--
ALTER TABLE `kategori_produk`
  ADD PRIMARY KEY (`id_kategori`);

--
-- Indexes for table `log_perubahan`
--
ALTER TABLE `log_perubahan`
  ADD PRIMARY KEY (`id_log`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`order_id`,`product_id`),
  ADD KEY `idx_quantity_price` (`quantity`,`price`);

--
-- Indexes for table `pengguna`
--
ALTER TABLE `pengguna`
  ADD PRIMARY KEY (`id_pengguna`);

--
-- Indexes for table `pesanan`
--
ALTER TABLE `pesanan`
  ADD PRIMARY KEY (`id_pesanan`),
  ADD KEY `id_pengguna` (`id_pengguna`);

--
-- Indexes for table `produk`
--
ALTER TABLE `produk`
  ADD PRIMARY KEY (`id_produk`);

--
-- Indexes for table `produk_kategori`
--
ALTER TABLE `produk_kategori`
  ADD PRIMARY KEY (`id_produk`,`id_kategori`),
  ADD KEY `id_kategori` (`id_kategori`);

--
-- Indexes for table `profil_pengguna`
--
ALTER TABLE `profil_pengguna`
  ADD PRIMARY KEY (`id_pengguna`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `review`
--
ALTER TABLE `review`
  ADD PRIMARY KEY (`id_review`),
  ADD KEY `id_pengguna` (`id_pengguna`),
  ADD KEY `id_produk` (`id_produk`),
  ADD KEY `idx_bintang_tanggal` (`bintang`,`tanggal_review`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `log_perubahan`
--
ALTER TABLE `log_perubahan`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `pengguna`
--
ALTER TABLE `pengguna`
  MODIFY `id_pengguna` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `pesanan`
--
ALTER TABLE `pesanan`
  MODIFY `id_pesanan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `review`
--
ALTER TABLE `review`
  MODIFY `id_review` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `detail_pesanan`
--
ALTER TABLE `detail_pesanan`
  ADD CONSTRAINT `detail_pesanan_ibfk_1` FOREIGN KEY (`id_pesanan`) REFERENCES `pesanan` (`id_pesanan`),
  ADD CONSTRAINT `detail_pesanan_ibfk_2` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`);

--
-- Constraints for table `detail_produk`
--
ALTER TABLE `detail_produk`
  ADD CONSTRAINT `detail_produk_ibfk_1` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`);

--
-- Constraints for table `pesanan`
--
ALTER TABLE `pesanan`
  ADD CONSTRAINT `pesanan_ibfk_1` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna` (`id_pengguna`);

--
-- Constraints for table `produk_kategori`
--
ALTER TABLE `produk_kategori`
  ADD CONSTRAINT `produk_kategori_ibfk_1` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`),
  ADD CONSTRAINT `produk_kategori_ibfk_2` FOREIGN KEY (`id_kategori`) REFERENCES `kategori_produk` (`id_kategori`);

--
-- Constraints for table `profil_pengguna`
--
ALTER TABLE `profil_pengguna`
  ADD CONSTRAINT `profil_pengguna_ibfk_1` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna` (`id_pengguna`);

--
-- Constraints for table `review`
--
ALTER TABLE `review`
  ADD CONSTRAINT `review_ibfk_1` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna` (`id_pengguna`),
  ADD CONSTRAINT `review_ibfk_2` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
