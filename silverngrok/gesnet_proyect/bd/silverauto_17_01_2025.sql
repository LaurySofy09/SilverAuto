-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 17, 2025 at 09:15 PM
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
-- Database: `silverauto`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_abrir_caja` (IN `p_monto_apertura` DECIMAL(13,2))   BEGIN

	  IF NOT EXISTS (SELECT * FROM `caja` WHERE DATE_FORMAT(`fecha_apertura`,'%Y-%m-%d') = curdate()) THEN

		INSERT INTO `caja`(`fecha_apertura`, `monto_apertura`)

		VALUES (NOW(), p_monto_apertura);

			ELSE

        UPDATE `caja` SET

        `estado` = 1

        WHERE DATE_FORMAT(`fecha_apertura`,'%Y-%m-%d') = curdate();

	  END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_abrir_inventario` ()   BEGIN

  DECLARE producto_count INT;

  SET producto_count = (SELECT COUNT(*) FROM producto);



    IF(producto_count != 0)THEN

	   IF NOT EXISTS (SELECT * FROM inventario WHERE fecha_apertura = DATE_FORMAT(CURDATE(),'%Y-%m-01')

	   AND fecha_cierre = LAST_DAY(CURDATE())) THEN



			 INSERT INTO `inventario`(`mes_inventario`,`fecha_apertura`, `fecha_cierre`,

			`saldo_inicial`, `entradas`, `salidas`, `saldo_final`, `estado`, `idproducto`)

			 SELECT DATE_FORMAT(CURDATE(),'%Y-%m'),DATE_FORMAT(CURDATE(),'%Y-%m-01'),LAST_DAY(CURDATE()),stock,

             0.00,0.00,stock, 1 ,idproducto

			 FROM producto WHERE estado = 1;



			 SELECT "ABIERTO" as respuesta;



			ELSE



			 UPDATE `inventario` SET

			`estado` = 1 WHERE `estado` = 0

			AND fecha_apertura = DATE_FORMAT(CURDATE(),'%Y-%m-01')

			AND fecha_cierre = LAST_DAY(CURDATE());



			SELECT "YA ABIERTO" as respuesta;



	   END IF;



       ELSE



		SELECT "SIN PRODUCTOS" as respuesta;



	END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_anular_apartado` (IN `p_idapartado` INT(11))   BEGIN	



		DECLARE p_numero_apartado varchar(175);

		DECLARE p_descripcion_movimiento varchar(80);

		SET p_numero_apartado = (SELECT numero_apartado FROM apartado WHERE idapartado = p_idapartado);

		SET p_descripcion_movimiento = (CONCAT('POR APARTADO #',' ',p_numero_apartado));







		DELETE FROM `caja_movimiento` 

        WHERE `descripcion_movimiento` = p_descripcion_movimiento;



		UPDATE `apartado` SET

		`estado` = 0

		WHERE idapartado = p_idapartado;

        

        DELETE FROM `salida`

        WHERE idapartado = p_idapartado;

        

		UPDATE inventario t2

		JOIN detalleapartado t1 ON t1.idproducto = t2.idproducto

        SET t2.salidas = t2.salidas - t1.cantidad,

        t2.saldo_final = t2.saldo_final + t1.cantidad

		WHERE t1.idapartado = p_idapartado AND t2.idproducto = t1.idproducto		

        AND t2.fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

		AND t2.fecha_cierre = LAST_DAY(CURDATE());



		UPDATE perecedero t2

		JOIN detalleapartado t1 ON t1.idproducto = t2.idproducto

		SET t2.cantidad_perecedero = t2.cantidad_perecedero + t1.cantidad

		WHERE t1.idapartado = p_idapartado AND t2.idproducto = t1.idproducto

        AND t2.fecha_vencimiento = t1.fecha_vence;



		UPDATE producto t2

		JOIN detalleapartado t1 ON t1.idproducto = t2.idproducto

		SET t2.stock = t2.stock + t1.cantidad

		WHERE t1.idapartado = p_idapartado AND t2.idproducto = t1.idproducto;





END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_anular_compra` (IN `p_idcompra` INT(11))   BEGIN



		DELETE FROM entrada

        WHERE idcompra = p_idcompra;



		UPDATE inventario t2

		JOIN detallecompra t1 ON t1.idproducto = t2.idproducto

		SET t2.saldo_final = t2.saldo_final - t1.cantidad,

        t2.entradas = t2.entradas - t1.cantidad

		WHERE t1.idcompra = p_idcompra AND t2.idproducto = t1.idproducto

        AND t2.fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

		AND t2.fecha_cierre = LAST_DAY(CURDATE());



		UPDATE perecedero t2

		JOIN detallecompra t1 ON t1.idproducto = t2.idproducto

		SET t2.cantidad_perecedero = t2.cantidad_perecedero - t1.cantidad

		WHERE t1.idcompra = p_idcompra AND t2.idproducto = t1.idproducto AND t2.fecha_vencimiento = t1.fecha_vence;



		UPDATE producto t2

		JOIN detallecompra t1 ON t1.idproducto = t2.idproducto

		SET t2.stock = t2.stock - t1.cantidad

		WHERE t1.idcompra = p_idcompra AND t2.idproducto = t1.idproducto;



		UPDATE compra SET

		estado = 0

		WHERE idcompra = p_idcompra;





END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_anular_venta` (IN `p_idventa` INT(11))   BEGIN



	DECLARE p_numero_comprobante INT;

	DECLARE p_tipo_comprobante tinyint(1);

    DECLARE p_fecha_venta date;

    DECLARE p_descripcion_movimiento varchar(150);

    DECLARE p_estado TINYINT(1);



    SET p_numero_comprobante = (SELECT numero_comprobante FROM venta WHERE idventa = p_idventa);

    SET p_tipo_comprobante = (SELECT tipo_comprobante FROM venta WHERE idventa = p_idventa);

    SET p_fecha_venta = (SELECT DATE_FORMAT(fecha_venta,'%Y-%m-%d') FROM venta WHERE idventa = p_idventa);

    SET p_estado = (SELECT estado FROM venta WHERE idventa = p_idventa);



 IF(p_estado = '1') THEN



    IF(p_tipo_comprobante = '1')THEN



		SET p_descripcion_movimiento = (CONCAT('POR VENTA',' ','TICKET', ' # ',p_numero_comprobante));



		DELETE FROM caja_movimiento WHERE

		descripcion_movimiento = (p_descripcion_movimiento) AND fecha_movimiento = p_fecha_venta;



        DELETE FROM salida

        WHERE idventa = p_idventa;



        UPDATE venta SET

        estado = 0

        WHERE idventa = p_idventa;



		UPDATE inventario t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

        SET t2.salidas = t2.salidas - t1.cantidad,

        t2.saldo_final = t2.saldo_final + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto

        AND t2.fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

		AND t2.fecha_cierre = LAST_DAY(CURDATE());



		UPDATE perecedero t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

		SET t2.cantidad_perecedero = t2.cantidad_perecedero + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto

        AND t2.fecha_vencimiento = t1.fecha_vence;



		UPDATE producto t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

		SET t2.stock = t2.stock + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto;





	ELSEIF (p_tipo_comprobante = '2')THEN





		SET p_descripcion_movimiento = (CONCAT('POR VENTA',' ','FACTURA', ' # ',p_numero_comprobante));



		DELETE FROM caja_movimiento WHERE

		descripcion_movimiento = (p_descripcion_movimiento) AND fecha_movimiento = p_fecha_venta;



		DELETE FROM salida

        WHERE idventa = p_idventa;



		UPDATE venta SET

        estado = 0

        WHERE idventa = p_idventa;



		UPDATE inventario t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

        SET t2.salidas = t2.salidas - t1.cantidad,

        t2.saldo_final = t2.saldo_final + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto

        AND t2.fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

		AND t2.fecha_cierre = LAST_DAY(CURDATE());



		UPDATE perecedero t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

		SET t2.cantidad_perecedero = t2.cantidad_perecedero + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto

        AND t2.fecha_vencimiento = t1.fecha_vence;



		UPDATE producto t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

		SET t2.stock = t2.stock + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto;



    ELSEIF (p_tipo_comprobante = '3')THEN





		SET p_descripcion_movimiento = CONCAT('POR VENTA',' ','BOLETA', ' # ',p_numero_comprobante);



		DELETE FROM caja_movimiento WHERE

		descripcion_movimiento = (p_descripcion_movimiento) AND fecha_movimiento = p_fecha_venta;



		DELETE FROM salida

        WHERE idventa = p_idventa;



		UPDATE venta SET

        estado = 0

        WHERE idventa = p_idventa;



		UPDATE inventario t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

        SET t2.salidas = t2.salidas - t1.cantidad,

        t2.saldo_final = t2.saldo_final + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto

        AND t2.fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

		AND t2.fecha_cierre = LAST_DAY(CURDATE());



		UPDATE perecedero t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

		SET t2.cantidad_perecedero = t2.cantidad_perecedero + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto

        AND t2.fecha_vencimiento = t1.fecha_vence;



		UPDATE producto t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

		SET t2.stock = t2.stock + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto;



    END IF;



 ELSEIF (p_estado = '2') THEN



    DELETE FROM credito WHERE idventa = p_idventa;



	IF(p_tipo_comprobante = '1')THEN



		SET p_descripcion_movimiento = (CONCAT('POR VENTA',' ','TICKET', ' # ',p_numero_comprobante));



		DELETE FROM caja_movimiento WHERE

		descripcion_movimiento = (p_descripcion_movimiento) AND fecha_movimiento = p_fecha_venta;



        DELETE FROM salida

        WHERE idventa = p_idventa;



        UPDATE venta SET

        estado = 0

        WHERE idventa = p_idventa;



		UPDATE inventario t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

        SET t2.salidas = t2.salidas - t1.cantidad,

        t2.saldo_final = t2.saldo_final + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto

        AND t2.fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

		AND t2.fecha_cierre = LAST_DAY(CURDATE());



		UPDATE perecedero t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

		SET t2.cantidad_perecedero = t2.cantidad_perecedero + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto

        AND t2.fecha_vencimiento = t1.fecha_vence;



		UPDATE producto t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

		SET t2.stock = t2.stock + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto;





	ELSEIF (p_tipo_comprobante = '2')THEN





		SET p_descripcion_movimiento = (CONCAT('POR VENTA',' ','FACTURA', ' # ',p_numero_comprobante));



		DELETE FROM caja_movimiento WHERE

		descripcion_movimiento = (p_descripcion_movimiento) AND fecha_movimiento = p_fecha_venta;



		DELETE FROM salida

        WHERE idventa = p_idventa;



		UPDATE venta SET

        estado = 0

        WHERE idventa = p_idventa;



		UPDATE inventario t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

        SET t2.salidas = t2.salidas - t1.cantidad,

        t2.saldo_final = t2.saldo_final + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto

        AND t2.fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

		AND t2.fecha_cierre = LAST_DAY(CURDATE());



		UPDATE perecedero t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

		SET t2.cantidad_perecedero = t2.cantidad_perecedero + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto

        AND t2.fecha_vencimiento = t1.fecha_vence;



		UPDATE producto t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

		SET t2.stock = t2.stock + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto;



    ELSEIF (p_tipo_comprobante = '3')THEN





		SET p_descripcion_movimiento = CONCAT('POR VENTA',' ','BOLETA', ' # ',p_numero_comprobante);



		DELETE FROM caja_movimiento WHERE

		descripcion_movimiento = (p_descripcion_movimiento) AND fecha_movimiento = p_fecha_venta;



		DELETE FROM salida

        WHERE idventa = p_idventa;



		UPDATE venta SET

        estado = 0

        WHERE idventa = p_idventa;



		UPDATE inventario t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

        SET t2.salidas = t2.salidas - t1.cantidad,

        t2.saldo_final = t2.saldo_final + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto

        AND t2.fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

		AND t2.fecha_cierre = LAST_DAY(CURDATE());



		UPDATE perecedero t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

		SET t2.cantidad_perecedero = t2.cantidad_perecedero + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto

        AND t2.fecha_vencimiento = t1.fecha_vence;



		UPDATE producto t2

		JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

		SET t2.stock = t2.stock + t1.cantidad

		WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto;



	END IF;



 END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cerrar_caja` (IN `p_monto_cierre` DECIMAL(13,2))   BEGIN



   DECLARE p_idcaja int(11);

   SET p_idcaja = (SELECT idcaja FROM `caja` WHERE DATE(fecha_apertura) = CURDATE());



	UPDATE `caja` SET

    `monto_cierre` = p_monto_cierre,

    `fecha_cierre` = NOW(),

    `estado` = 0

     WHERE idcaja = p_idcaja;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cerrar_caja_manual` (IN `p_id` INT)   BEGIN

	UPDATE caja SET

    estado = 0 WHERE idcaja = p_id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cerrar_inventario` ()   BEGIN



		UPDATE `inventario` SET

		`estado` = 0 WHERE `estado` = 1

        AND fecha_apertura != DATE_FORMAT(CURDATE(),'%Y-%m-01')

		AND fecha_cierre != LAST_DAY(CURDATE()) ;







	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cerrar_inventario_manual` ()   BEGIN



		UPDATE `inventario` SET

		`estado` = 0 WHERE `estado` = 1

        AND fecha_apertura = DATE_FORMAT(CURDATE(),'%Y-%m-01')

		AND fecha_cierre = LAST_DAY(CURDATE()) ;



		SELECT "CERRADO" as respuesta;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_compras_anual` ()   BEGIN



	DECLARE count_compra INT;

    SET count_compra = (SELECT COUNT(*) FROM compra WHERE estado = 1);



	IF (count_compra > 0 ) THEN



	SELECT IF (UCASE(DATE_FORMAT(fecha_compra,'%b')) IS NULL,'0.00',

    UCASE(DATE_FORMAT(fecha_compra,'%b'))) as mes,

    IF(SUM(total) IS NULL, 0.00, SUM(total)) as total FROM compra

	WHERE YEAR(fecha_compra) = YEAR(CURDATE()) AND estado = 1 GROUP BY MONTH(fecha_compra);



    ELSE



    SELECT '-' as mes,'0.00' as total;





    END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ConsultarVentasCredito` ()   SELECT 
            v.idventa, 
            v.fecha_factura, 
            TIMESTAMPDIFF(DAY, v.fecha_factura, NOW()) AS dias_transcurridos,
            d.cantidad_dias,
            v.numero_venta, 
            COALESCE(v.idcliente, 0) AS idcliente,
            c.nombre_cliente, 
            GROUP_CONCAT(CONCAT(p.nombre_producto, ' (', dv.precio_unitario, ')') SEPARATOR ', ') AS productos_y_precios,
            v.sumas, 
            v.total
        FROM 
            `venta` AS v 
        INNER JOIN 
            detalleventa AS dv 
        ON 
            v.idventa = dv.idventa
        INNER JOIN 
            cliente AS c 
        ON 
            v.idcliente = c.idcliente
        INNER JOIN 
            dias AS d 
         ON 
            c.iddias = d.iddias
        INNER JOIN 
            producto AS p 
        ON 
            dv.idproducto = p.idproducto
        WHERE 
            v.facturado = 1 AND v.tipoVenta = 2
        GROUP BY 
            v.idventa, v.fecha_venta, v.numero_venta, v.idcliente, c.nombre_cliente
        ORDER BY 
            v.idventa DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ConsultarVentasFact` (IN `P_FlagConsulta` INT)   BEGIN
    IF P_FlagConsulta = 1 THEN
        SELECT 
            v.idventa, 
            v.fecha_venta, 
            v.numero_venta, 
            COALESCE(v.idcliente, 0) AS idcliente,
            c.nombre_cliente, 
            dv.cantidad,
            GROUP_CONCAT(CONCAT(p.nombre_producto, ' (', dv.precio_unitario, ')') SEPARATOR ', ') AS productos_y_precios,
            v.sumas, 
            v.iva,
            v.exento,
            v.retenido,
            v.descuento,
            v.total
        FROM 
            `venta` AS v 
        INNER JOIN 
            detalleventa AS dv 
        ON 
            v.idventa = dv.idventa
        INNER JOIN 
            cliente AS c 
        ON 
            v.idcliente = c.idcliente
        INNER JOIN 
            producto AS p 
        ON 
            dv.idproducto = p.idproducto
        WHERE 
            v.facturado = 1
        GROUP BY 
            v.idventa, v.fecha_venta, v.numero_venta, v.idcliente, c.nombre_cliente
        ORDER BY 
            v.idventa DESC;
    ELSE
        SELECT 
            v.idventa, 
            v.fecha_venta, 
            v.numero_venta, 
            COALESCE(v.idcliente, 0) AS idcliente,
            c.nombre_cliente, 
            dv.cantidad,
            GROUP_CONCAT(CONCAT(p.nombre_producto, ' (', dv.precio_unitario, ')') SEPARATOR ', ') AS productos_y_precios,
            v.sumas, 
            v.iva,
            v.exento,
            v.retenido,
            v.descuento,
            v.total
        FROM 
            `venta` AS v 
        INNER JOIN 
            detalleventa AS dv 
        ON 
            v.idventa = dv.idventa
        INNER JOIN 
            cliente AS c 
        ON 
            v.idcliente = c.idcliente
        INNER JOIN 
            producto AS p 
        ON 
            dv.idproducto = p.idproducto
        WHERE 
            v.facturado != 1 OR v.Facturado IS NULL
        GROUP BY 
            v.idventa, v.fecha_venta, v.numero_venta, v.idcliente, c.nombre_cliente
        ORDER BY 
            v.idventa DESC;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consultar_detallesorden` (IN `p_idorden` INT)   BEGIN

SELECT d.idDetalle, d.idorden, d.idproducto, d.precio, p.nombre_producto, d.cantidad 
FROM detalle_ordentaller d INNER JOIN producto p  on d.idproducto = p.idproducto where d.idorden = p_idorden;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consulta_apartados` (IN `p_criterio` VARCHAR(10), IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10), IN `p_estado` VARCHAR(2))   BEGIN



		IF(p_criterio = 'MES') THEN



		  IF (p_date = '')THEN



				IF(p_estado = '') THEN

					SELECT * FROM view_apartados WHERE MONTH(fecha_apartado) = MONTH(CURDATE())

                    GROUP BY numero_apartado;



				ELSEIF (p_estado != '') THEN



					SELECT * FROM view_apartados WHERE MONTH(fecha_apartado) = MONTH(CURDATE())

					AND estado_apartado = p_estado  GROUP BY numero_apartado;





				END IF;





			ELSE



				IF(p_estado = '') THEN

					SELECT * FROM view_apartados WHERE MONTH(fecha_apartado) = p_date 

                     GROUP BY numero_apartado;





				ELSEIF (p_estado != '') THEN



					SELECT * FROM view_apartados WHERE MONTH(fecha_apartado) = p_date

					AND estado_apartado = p_estado  GROUP BY numero_apartado;





				END IF;



		  END IF;



		ELSEIF (p_criterio = 'FECHAS') THEN



		   IF (p_date = '' AND p_date2 ='')THEN



				IF(p_estado = '') THEN

					SELECT * FROM view_apartados WHERE MONTH(fecha_apartado) = MONTH(CURDATE())

                     GROUP BY numero_apartado;





				ELSEIF (p_estado != '') THEN



					SELECT * FROM view_apartados WHERE MONTH(fecha_apartado) = MONTH(CURDATE())

					AND estado_apartado = p_estado  GROUP BY numero_apartado;





				END IF;



			ELSE



				IF(p_estado = '') THEN

					SELECT * FROM view_apartados WHERE fecha_apartado BETWEEN p_date AND p_date2

                     GROUP BY numero_apartado;



				ELSEIF (p_estado != '') THEN



					SELECT * FROM view_apartados WHERE fecha_apartado BETWEEN p_date AND p_date2

					AND estado_apartado = p_estado GROUP BY numero_apartado;





				END IF;



			END IF;



		ELSEIF (p_criterio = 'HOY') THEN



				IF(p_estado = '') THEN

					SELECT * FROM view_apartados WHERE DATE_FORMAT(fecha_apartado,'%Y-%m-%d') = CURDATE()

                     GROUP BY numero_apartado;



				ELSEIF (p_estado != '') THEN



					SELECT * FROM view_apartados WHERE DATE_FORMAT(fecha_apartado,'%Y-%m-%d') = CURDATE()

					AND estado_apartado = p_estado GROUP BY numero_apartado;



				END IF;



        END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consulta_apartados_detalle` (IN `p_criterio` VARCHAR(10), IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10), IN `p_estado` VARCHAR(2))   BEGIN





		IF(p_criterio = 'MES') THEN



		  IF (p_date = '')THEN



				IF(p_estado = '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_apartados WHERE MONTH(fecha_apartado) = MONTH(CURDATE()) ;



				ELSEIF (p_estado != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_apartados WHERE MONTH(fecha_apartado) = MONTH(CURDATE())

					AND estado_apartado = p_estado

					;



				END IF;





			ELSE



				IF(p_estado = '') THEN

					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_apartados WHERE MONTH(fecha_apartado) = p_date;



				ELSEIF (p_estado != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_apartados WHERE MONTH(fecha_apartado) = p_date

					AND estado_apartado = p_estado

					;



				END IF;



		  END IF;



		ELSEIF (p_criterio = 'FECHAS') THEN



		   IF (p_date = '' AND p_date2 ='')THEN



				IF(p_estado = '') THEN

					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_apartados WHERE MONTH(fecha_apartado) = MONTH(CURDATE())

					;



				ELSEIF (p_estado != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_apartados WHERE MONTH(fecha_apartado) = MONTH(CURDATE())

					AND estado_apartado = p_estado

					;



				END IF;



			ELSE



				IF(p_estado = '') THEN

					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_apartados WHERE fecha_apartado BETWEEN p_date AND p_date2

					;



				ELSEIF (p_estado != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_apartados WHERE fecha_apartado BETWEEN p_date AND p_date2

					AND estado_apartado = p_estado

					;



				END IF;



			END IF;



		ELSEIF (p_criterio = 'HOY') THEN



				IF(p_estado = '') THEN

					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_apartados WHERE DATE_FORMAT(fecha_apartado,'%Y-%m-%d') = CURDATE()

					;



				ELSEIF (p_estado != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_apartados WHERE DATE_FORMAT(fecha_apartado,'%Y-%m-%d') = CURDATE()

					AND estado_apartado = p_estado

					;



				END IF;



        END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consulta_apartados_totales` (IN `p_criterio` VARCHAR(10), IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10), IN `p_estado` VARCHAR(2))   BEGIN



		IF(p_criterio = 'MES') THEN



		  IF (p_date = '')THEN



				IF(p_estado = '') THEN

					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_apartado FROM apartado

                    WHERE MONTH(fecha_apartado) = MONTH(CURDATE());



				ELSEIF (p_estado != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_apartado FROM apartado

                    WHERE MONTH(fecha_apartado) = MONTH(CURDATE())

					AND estado = p_estado;



				END IF;





			ELSE



				IF(p_estado = '') THEN

					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_apartado FROM apartado

                    WHERE MONTH(fecha_apartado) = p_date;



				ELSEIF (p_estado != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_apartado FROM apartado

                    WHERE MONTH(fecha_apartado) = p_date

					AND estado = p_estado;



				END IF;



		  END IF;



		ELSEIF (p_criterio = 'FECHAS') THEN



		   IF (p_date = '' AND p_date2 ='')THEN



				IF(p_estado = '') THEN

					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_apartado FROM apartado

                    WHERE MONTH(fecha_apartado) = MONTH(CURDATE());



				ELSEIF (p_estado != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_apartado FROM apartado

                    WHERE MONTH(fecha_apartado) = MONTH(CURDATE());



				END IF;



			ELSE



				IF(p_estado = '') THEN

					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_apartado FROM apartado

                    WHERE fecha_apartado BETWEEN p_date AND p_date2;



				ELSEIF (p_estado != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_apartado FROM apartado

                    WHERE fecha_apartado BETWEEN p_date AND p_date2

					AND estado = p_estado;



				END IF;



			END IF;



		ELSEIF (p_criterio = 'HOY') THEN



				IF(p_estado = '') THEN

					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_apartado FROM apartado

                    WHERE DATE_FORMAT(fecha_apartado,'%Y-%m-%d') = CURDATE();



				ELSEIF (p_estado != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_apartado FROM apartado

                    WHERE DATE_FORMAT(fecha_apartado,'%Y-%m-%d') = CURDATE()

					AND estado = p_estado;



				END IF;



        END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consulta_compras` (IN `p_criterio` VARCHAR(10), IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10), IN `p_estado` VARCHAR(2), IN `p_pago` VARCHAR(2))   BEGIN



		IF(p_criterio = 'MES') THEN



		  IF (p_date = '')THEN



				IF(p_estado = '' AND p_pago = '') THEN

					SELECT * FROM view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					GROUP BY fecha_comprobante , numero_comprobante;



				ELSEIF (p_estado != '' AND p_pago = '') THEN



					SELECT * FROM view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND estado_compra = p_estado

					GROUP BY fecha_comprobante , numero_comprobante;



				ELSEIF (p_estado = '' AND p_pago != '') THEN



					SELECT * FROM view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND tipo_pago = p_pago

					GROUP BY fecha_comprobante , numero_comprobante;



				ELSEIF (p_estado != '' AND p_pago != '') THEN



					SELECT * FROM view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND estado_compra = p_estado AND tipo_pago	= p_pago

					GROUP BY fecha_comprobante , numero_comprobante;



				END IF;





			ELSE



				IF(p_estado = '' AND p_pago = '') THEN

					SELECT * FROM view_compras WHERE MONTH(fecha_compra) = p_date

					GROUP BY fecha_comprobante , numero_comprobante;



				ELSEIF (p_estado != '' AND p_pago = '') THEN



					SELECT * FROM view_compras WHERE MONTH(fecha_compra) = p_date

					AND estado_compra = p_estado

					GROUP BY fecha_comprobante , numero_comprobante;



				ELSEIF (p_estado = '' AND p_pago != '') THEN



					SELECT * FROM view_compras WHERE MONTH(fecha_compra) = p_date

					AND tipo_pago = p_pago

					GROUP BY fecha_comprobante , numero_comprobante;



				ELSEIF (p_estado != '' AND p_pago != '') THEN



					SELECT * FROM view_compras WHERE MONTH(fecha_compra) = p_date

					AND estado_compra = p_estado AND tipo_pago	= p_pago

					GROUP BY fecha_comprobante , numero_comprobante;



				END IF;



		  END IF;



		ELSEIF (p_criterio = 'FECHAS') THEN



		   IF (p_date = '' AND p_date2 ='')THEN



				IF(p_estado = '' AND p_pago = '') THEN

					SELECT * FROM view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					GROUP BY fecha_comprobante , numero_comprobante;



				ELSEIF (p_estado != '' AND p_pago = '') THEN



					SELECT * FROM view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND estado_compra = p_estado

					GROUP BY fecha_comprobante , numero_comprobante;



				ELSEIF (p_estado = '' AND p_pago != '') THEN



					SELECT * FROM view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND tipo_pago = p_pago


					GROUP BY fecha_comprobante , numero_comprobante;



				ELSEIF (p_estado != '' AND p_pago != '') THEN



					SELECT * FROM view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND estado_compra = p_estado AND tipo_pago	= p_pago

					GROUP BY fecha_comprobante , numero_comprobante;



				END IF;



			ELSE



				IF(p_estado = '' AND p_pago = '') THEN

					SELECT * FROM view_compras WHERE fecha_compra BETWEEN p_date AND p_date2

					GROUP BY fecha_comprobante , numero_comprobante;



				ELSEIF (p_estado != '' AND p_pago = '') THEN



					SELECT * FROM view_compras WHERE fecha_compra BETWEEN p_date AND p_date2

					AND estado_compra = p_estado

					GROUP BY fecha_comprobante , numero_comprobante;



				ELSEIF (p_estado = '' AND p_pago != '') THEN



					SELECT * FROM view_compras WHERE fecha_compra BETWEEN p_date AND p_date2

					AND tipo_pago = p_pago

					GROUP BY fecha_comprobante , numero_comprobante;



				ELSEIF (p_estado != '' AND p_pago != '') THEN



					SELECT * FROM view_compras WHERE fecha_compra BETWEEN p_date AND p_date2

					AND estado_compra = p_estado AND tipo_pago	= p_pago

					GROUP BY fecha_comprobante , numero_comprobante;



				END IF;



			END IF;



        END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consulta_compras_detalle` (IN `p_criterio` VARCHAR(10), IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10), IN `p_estado` VARCHAR(2), IN `p_pago` VARCHAR(2))   BEGIN



		IF(p_criterio = 'MES') THEN



		  IF (p_date = '')THEN



				IF(p_estado = '' AND p_pago = '') THEN

					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE());



				ELSEIF (p_estado != '' AND p_pago = '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND estado_compra = p_estado;



				ELSEIF (p_estado = '' AND p_pago != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND tipo_pago = p_pago;



				ELSEIF (p_estado != '' AND p_pago != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND estado_compra = p_estado AND tipo_pago	= p_pago;



				END IF;





			ELSE



				IF(p_estado = '' AND p_pago = '') THEN

					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE MONTH(fecha_compra) = p_date;




				ELSEIF (p_estado != '' AND p_pago = '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE MONTH(fecha_compra) = p_date

					AND estado_compra = p_estado;



				ELSEIF (p_estado = '' AND p_pago != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE MONTH(fecha_compra) = p_date

					AND tipo_pago = p_pago;



				ELSEIF (p_estado != '' AND p_pago != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE MONTH(fecha_compra) = p_date

					AND estado_compra = p_estado AND tipo_pago	= p_pago;



				END IF;



		  END IF;



		ELSEIF (p_criterio = 'FECHAS') THEN



		   IF (p_date = '' AND p_date2 ='')THEN



				IF(p_estado = '' AND p_pago = '') THEN

					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE());



				ELSEIF (p_estado != '' AND p_pago = '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND estado_compra = p_estado;



				ELSEIF (p_estado = '' AND p_pago != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND tipo_pago = p_pago;



				ELSEIF (p_estado != '' AND p_pago != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND estado_compra = p_estado AND tipo_pago	= p_pago;



				END IF;



			ELSE



				IF(p_estado = '' AND p_pago = '') THEN

					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE fecha_compra BETWEEN p_date AND p_date2;



				ELSEIF (p_estado != '' AND p_pago = '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE fecha_compra BETWEEN p_date AND p_date2

					AND estado_compra = p_estado;



				ELSEIF (p_estado = '' AND p_pago != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE fecha_compra BETWEEN p_date AND p_date2

					AND tipo_pago = p_pago;



				ELSEIF (p_estado != '' AND p_pago != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,importe FROM

					view_compras WHERE fecha_compra BETWEEN p_date AND p_date2

					AND estado_compra = p_estado AND tipo_pago	= p_pago;



				END IF;



			END IF;



        END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consulta_compras_totales` (IN `p_criterio` VARCHAR(10), IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10), IN `p_estado` VARCHAR(2), IN `p_pago` VARCHAR(2))   BEGIN



		IF(p_criterio = 'MES') THEN



		  IF (p_date = '')THEN



				IF(p_estado = '' AND p_pago = '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra WHERE MONTH(fecha_compra) = MONTH(CURDATE());



				ELSEIF (p_estado != '' AND p_pago = '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra  WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND estado = p_estado;



				ELSEIF (p_estado = '' AND p_pago != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra  WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND tipo_pago = p_pago;



				ELSEIF (p_estado != '' AND p_pago != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra  WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND estado = p_estado AND tipo_pago	= p_pago;



				END IF;





			ELSE



				IF(p_estado = '' AND p_pago = '') THEN

					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra  WHERE MONTH(fecha_compra) = p_date;



				ELSEIF (p_estado != '' AND p_pago = '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra  WHERE MONTH(fecha_compra) = p_date

					AND estado = p_estado;



				ELSEIF (p_estado = '' AND p_pago != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra  WHERE MONTH(fecha_compra) = p_date

					AND tipo_pago = p_pago;



				ELSEIF (p_estado != '' AND p_pago != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra WHERE MONTH(fecha_compra) = p_date

					AND estado = p_estado AND tipo_pago	= p_pago;



				END IF;



		  END IF;



		ELSEIF (p_criterio = 'FECHAS') THEN



		   IF (p_date = '' AND p_date2 ='')THEN



				IF(p_estado = '' AND p_pago = '') THEN

					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra  WHERE MONTH(fecha_compra) = MONTH(CURDATE());



				ELSEIF (p_estado != '' AND p_pago = '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND estado = p_estado;



				ELSEIF (p_estado = '' AND p_pago != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra  WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND tipo_pago = p_pago;



				ELSEIF (p_estado != '' AND p_pago != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra  WHERE MONTH(fecha_compra) = MONTH(CURDATE())

					AND estado = p_estado AND tipo_pago	= p_pago;



				END IF;



			ELSE



				IF(p_estado = '' AND p_pago = '') THEN

					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra  WHERE fecha_compra BETWEEN p_date AND p_date2;



				ELSEIF (p_estado != '' AND p_pago = '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra  WHERE fecha_compra BETWEEN p_date AND p_date2

					AND estado = p_estado;



				ELSEIF (p_estado = '' AND p_pago != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra  WHERE fecha_compra BETWEEN p_date AND p_date2

					AND tipo_pago = p_pago;



				ELSEIF (p_estado != '' AND p_pago != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

					SUM(retenido) as total_retenido, SUM(total) as total_comprado

                    FROM compra  WHERE fecha_compra BETWEEN p_date AND p_date2

					AND estado = p_estado AND tipo_pago	= p_pago;



				END IF;



			END IF;



        END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consulta_historico_precios` (IN `p_idproducto` INT(11))   BEGIN



		SELECT * FROM view_historico_precios WHERE idproducto = p_idproducto;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consulta_precio_mas_bajo` (IN `p_idproducto` INT(11))   BEGIN



		SELECT * FROM view_historico_precios WHERE idproducto = p_idproducto

        AND precio_comprado = (SELECT MIN(precio_comprado) FROM  view_historico_precios

        WHERE idproducto = p_idproducto);



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consulta_ventas` (IN `p_criterio` VARCHAR(10), IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10), IN `p_estado` VARCHAR(2))   BEGIN



		IF(p_criterio = 'MES') THEN



		  IF (p_date = '')THEN



				IF(p_estado = '') THEN

					SELECT * FROM view_ventas WHERE MONTH(fecha_venta) = MONTH(CURDATE())

					GROUP BY DATE_FORMAT(fecha_venta,'%Y-%m-%d'), numero_comprobante;



				ELSEIF (p_estado != '') THEN



					SELECT * FROM view_ventas WHERE MONTH(fecha_venta) = MONTH(CURDATE())

					AND estado_venta = p_estado

					GROUP BY DATE_FORMAT(fecha_venta,'%Y-%m-%d'), numero_comprobante;



				END IF;





			ELSE



				IF(p_estado = '') THEN

					SELECT * FROM view_ventas WHERE MONTH(fecha_venta) = p_date

					GROUP BY DATE_FORMAT(fecha_venta,'%Y-%m-%d'), numero_comprobante;



				ELSEIF (p_estado != '') THEN



					SELECT * FROM view_ventas WHERE MONTH(fecha_venta) = p_date

					AND estado_venta = p_estado

					GROUP BY DATE_FORMAT(fecha_venta,'%Y-%m-%d'), numero_comprobante;



				END IF;



		  END IF;



		ELSEIF (p_criterio = 'FECHAS') THEN



		   IF (p_date = '' AND p_date2 ='')THEN



				IF(p_estado = '') THEN

					SELECT * FROM view_ventas WHERE MONTH(fecha_venta) = MONTH(CURDATE())

					GROUP BY DATE_FORMAT(fecha_venta,'%Y-%m-%d'), numero_comprobante;



				ELSEIF (p_estado != '') THEN



					SELECT * FROM view_ventas WHERE MONTH(fecha_venta) = MONTH(CURDATE())

					AND estado_venta = p_estado

					GROUP BY DATE_FORMAT(fecha_venta,'%Y-%m-%d'), numero_comprobante;



				END IF;



			ELSE



				IF(p_estado = '') THEN

					SELECT * FROM view_ventas WHERE fecha_venta BETWEEN p_date AND p_date2

					GROUP BY DATE_FORMAT(fecha_venta,'%Y-%m-%d'), numero_comprobante;



				ELSEIF (p_estado != '') THEN



					SELECT * FROM view_ventas WHERE fecha_venta BETWEEN p_date AND p_date2

					AND estado_venta = p_estado

					GROUP BY DATE_FORMAT(fecha_venta,'%Y-%m-%d'), numero_comprobante;



				END IF;



			END IF;



		ELSEIF (p_criterio = 'HOY') THEN



				IF(p_estado = '') THEN

					SELECT * FROM view_ventas WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = CURDATE()

					GROUP BY DATE_FORMAT(fecha_venta,'%Y-%m-%d'), numero_comprobante;



				ELSEIF (p_estado != '') THEN



					SELECT * FROM view_ventas WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = CURDATE()

					AND estado_venta = p_estado

					GROUP BY DATE_FORMAT(fecha_venta,'%Y-%m-%d'), numero_comprobante;



				END IF;



        END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consulta_ventas_detalle` (IN `p_criterio` VARCHAR(10), IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10), IN `p_estado` VARCHAR(2))   BEGIN





		IF(p_criterio = 'MES') THEN



		  IF (p_date = '')THEN



				IF(p_estado = '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_ventas WHERE MONTH(fecha_venta) = MONTH(CURDATE())

					;



				ELSEIF (p_estado != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_ventas WHERE MONTH(fecha_venta) = MONTH(CURDATE())

					AND estado_venta = p_estado

					;



				END IF;





			ELSE



				IF(p_estado = '') THEN

					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_ventas WHERE MONTH(fecha_venta) = p_date

					;



				ELSEIF (p_estado != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_ventas WHERE MONTH(fecha_venta) = p_date

					AND estado_venta = p_estado

					;



				END IF;



		  END IF;



		ELSEIF (p_criterio = 'FECHAS') THEN



		   IF (p_date = '' AND p_date2 ='')THEN



				IF(p_estado = '') THEN

					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_ventas WHERE MONTH(fecha_venta) = MONTH(CURDATE())

					;



				ELSEIF (p_estado != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_ventas WHERE MONTH(fecha_venta) = MONTH(CURDATE())

					AND estado_venta = p_estado

					;



				END IF;



			ELSE



				IF(p_estado = '') THEN

					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_ventas WHERE fecha_venta BETWEEN p_date AND p_date2

					;



				ELSEIF (p_estado != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_ventas WHERE fecha_venta BETWEEN p_date AND p_date2

					AND estado_venta = p_estado

					;



				END IF;



			END IF;



		ELSEIF (p_criterio = 'HOY') THEN



				IF(p_estado = '') THEN

					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_ventas WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = CURDATE()

					;



				ELSEIF (p_estado != '') THEN



					SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

					nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,(importe-descuento)

                    as importe,sumas,

					iva,total_exento,retenido,total_descuento,total,fecha_vence,precio_compra,

					((precio_unitario - precio_compra) * cantidad) - descuento AS utilidad_total

					FROM view_ventas WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = CURDATE()

					AND estado_venta = p_estado

					;



				END IF;



        END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consulta_ventas_totales` (IN `p_criterio` VARCHAR(10), IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10), IN `p_estado` VARCHAR(2))   BEGIN



		IF(p_criterio = 'MES') THEN



		  IF (p_date = '')THEN



				IF(p_estado = '') THEN

					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_vendido FROM venta

                    WHERE MONTH(fecha_venta) = MONTH(CURDATE());



				ELSEIF (p_estado != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_vendido FROM venta

                    WHERE MONTH(fecha_venta) = MONTH(CURDATE())

					AND estado = p_estado;



				END IF;





			ELSE



				IF(p_estado = '') THEN

					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_vendido FROM venta

                    WHERE MONTH(fecha_venta) = p_date;



				ELSEIF (p_estado != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_vendido FROM venta

                    WHERE MONTH(fecha_venta) = p_date

					AND estado = p_estado;



				END IF;



		  END IF;



		ELSEIF (p_criterio = 'FECHAS') THEN



		   IF (p_date = '' AND p_date2 ='')THEN



				IF(p_estado = '') THEN

					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_vendido FROM venta

                    WHERE MONTH(fecha_venta) = MONTH(CURDATE());



				ELSEIF (p_estado != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_vendido FROM venta

                    WHERE MONTH(fecha_venta) = MONTH(CURDATE());



				END IF;



			ELSE



				IF(p_estado = '') THEN

					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_vendido FROM venta

                    WHERE fecha_venta BETWEEN p_date AND p_date2;



				ELSEIF (p_estado != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_vendido FROM venta

                    WHERE fecha_venta BETWEEN p_date AND p_date2

					AND estado = p_estado;



				END IF;



			END IF;



		ELSEIF (p_criterio = 'HOY') THEN



				IF(p_estado = '') THEN

					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_vendido FROM venta

                    WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = CURDATE();



				ELSEIF (p_estado != '') THEN



					SELECT SUM(iva) as total_iva, SUM(exento) as total_exento,

                    SUM(retenido) as total_retenido, SUM(descuento) as total_descuento,

                    SUM(total) as total_vendido FROM venta

                    WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = CURDATE()

					AND estado = p_estado;



				END IF;



        END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consulta_view_productos` ()   BEGIN

SELECT * FROM view_productos;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_corte_z_day` (IN `p_day` DATE)   BEGIN



	DECLARE p_desde_impreso INT;

    DECLARE p_hasta_impreso INT;

    DECLARE p_venta_gravada DECIMAL(13,2);

    DECLARE p_venta_iva DECIMAL(13,2);

	DECLARE p_total_exento DECIMAL(13,2);

    DECLARE p_total_gravado DECIMAL(13,2);

    DECLARE p_total_descuento DECIMAL(13,2);

    DECLARE p_total_venta DECIMAL(13,2);



    IF (p_day!='') THEN



		SET p_desde_impreso = (SELECT MIN(numero_comprobante) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = p_day AND tipo_comprobante = 1);



		SET p_hasta_impreso = (SELECT MAX(numero_comprobante) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = p_day AND tipo_comprobante = 1);



		SET p_venta_gravada = (SELECT SUM(sumas) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = p_day AND tipo_comprobante = 1);



		SET p_venta_iva = (SELECT SUM(iva) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = p_day AND tipo_comprobante = 1);



		SET p_total_exento = (SELECT SUM(exento) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = p_day AND tipo_comprobante = 1);

        

		SET p_total_descuento = (SELECT SUM(descuento) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = p_day AND tipo_comprobante = 1);



        SET p_total_gravado = (p_venta_gravada + p_venta_iva);

        SET p_total_venta = (p_total_gravado + p_total_exento) - p_total_descuento;



        SELECT p_desde_impreso, p_hasta_impreso, p_venta_gravada, p_venta_iva ,

        p_total_exento , p_total_gravado , p_total_descuento, p_total_venta;



	ELSE



		SET p_desde_impreso = (SELECT MIN(numero_comprobante) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = CURDATE() AND tipo_comprobante = 1);



		SET p_hasta_impreso = (SELECT MAX(numero_comprobante) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = CURDATE() AND tipo_comprobante = 1);



		SET p_venta_gravada = (SELECT SUM(sumas) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = CURDATE() AND tipo_comprobante = 1);



		SET p_venta_iva = (SELECT SUM(iva) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = CURDATE() AND tipo_comprobante = 1);



		SET p_total_exento = (SELECT SUM(exento) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = CURDATE() AND tipo_comprobante = 1);

        

		SET p_total_descuento = (SELECT SUM(descuento) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = CURDATE()  AND tipo_comprobante = 1);



        SET p_total_gravado = (p_venta_gravada + p_venta_iva);

        SET p_total_venta = (p_total_gravado + p_total_exento) - p_total_descuento;



        SELECT p_desde_impreso, p_hasta_impreso, p_venta_gravada, p_venta_iva ,

        p_total_exento , p_total_gravado , p_total_descuento, p_total_venta;



    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_corte_z_mes` (IN `p_month` VARCHAR(7))   BEGIN



	DECLARE p_desde_impreso INT;

    DECLARE p_hasta_impreso INT;

    DECLARE p_venta_gravada DECIMAL(13,2);

    DECLARE p_venta_iva DECIMAL(13,2);

	DECLARE p_total_exento DECIMAL(13,2);

    DECLARE p_total_gravado DECIMAL(13,2);

	DECLARE p_total_descuento DECIMAL(13,2);

    DECLARE p_total_venta DECIMAL(13,2);



    IF (p_month!='') THEN



		SET p_desde_impreso = (SELECT MIN(numero_comprobante) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%m-%Y') = p_month AND tipo_comprobante = 1);



		SET p_hasta_impreso = (SELECT MAX(numero_comprobante) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%m-%Y') = p_month AND tipo_comprobante = 1);



		SET p_venta_gravada = (SELECT SUM(sumas) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%m-%Y') = p_month AND tipo_comprobante = 1);



		SET p_venta_iva = (SELECT SUM(iva) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%m-%Y') = p_month AND tipo_comprobante = 1);



		SET p_total_exento = (SELECT SUM(exento) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%m-%Y') = p_month AND tipo_comprobante = 1);

        

        SET p_total_descuento = (SELECT SUM(descuento) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%m-%Y') = p_month AND tipo_comprobante = 1);



        SET p_total_gravado = (p_venta_gravada + p_venta_iva);

        SET p_total_venta = (p_total_gravado + p_total_exento) - p_total_descuento;



        SELECT p_desde_impreso, p_hasta_impreso, p_venta_gravada, p_venta_iva ,

        p_total_exento , p_total_gravado , p_total_descuento, p_total_venta;



	ELSE



		SET p_desde_impreso = (SELECT MIN(numero_comprobante) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%m-%Y') =  MONTH(CURDATE()) AND tipo_comprobante = 1);



		SET p_hasta_impreso = (SELECT MAX(numero_comprobante) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%m-%Y') =  MONTH(CURDATE()) AND tipo_comprobante = 1);



		SET p_venta_gravada = (SELECT SUM(sumas) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%m-%Y') =  MONTH(CURDATE()) AND tipo_comprobante = 1);



		SET p_venta_iva = (SELECT SUM(iva) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%m-%Y') =  MONTH(CURDATE()) AND tipo_comprobante = 1);



		SET p_total_exento = (SELECT SUM(exento) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%m-%Y') =  MONTH(CURDATE()) AND tipo_comprobante = 1);

        

		SET p_total_descuento = (SELECT SUM(descuento) FROM venta

		WHERE DATE_FORMAT(fecha_venta,'%m-%Y') = MONTH(CURDATE()) AND tipo_comprobante = 1);



        SET p_total_gravado = (p_venta_gravada + p_venta_iva);

        SET p_total_venta = (p_total_gravado + p_total_exento) - p_total_descuento;



        SELECT p_desde_impreso, p_hasta_impreso, p_venta_gravada, p_venta_iva ,

        p_total_exento , p_total_gravado , p_total_descuento, p_total_venta;



    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_count_apartados` (IN `p_criterio` VARCHAR(10), IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10))   BEGIN



       DECLARE apartados_anuladas INT;

       DECLARE apartados_vigentes INT;

	   DECLARE apartados_saldados INT;



   IF (p_criterio = 'MES') THEN



     IF (p_date = '') THEN



       SET apartados_anuladas = (SELECT COUNT(*) AS apartados_anuladas

	   FROM apartado WHERE estado = 0 AND DATE_FORMAT(fecha_apartado,'%m-%Y') =  MONTH(CURDATE()));

       SET apartados_vigentes = (SELECT COUNT(*) AS apartados_vigentes

	   FROM apartado WHERE estado = 1 AND DATE_FORMAT(fecha_apartado,'%m-%Y') = MONTH(CURDATE()));

	   SET apartados_saldados = (SELECT COUNT(*) AS apartados_vigentes

	   FROM apartado WHERE estado = 2 AND DATE_FORMAT(fecha_apartado,'%m-%Y') = MONTH(CURDATE()));



		SELECT apartados_anuladas,apartados_vigentes,apartados_saldados;



     ELSE



       SET apartados_anuladas = (SELECT COUNT(*) AS apartados_anuladas FROM apartado

	   WHERE DATE_FORMAT(fecha_apartado,'%m-%Y') = p_date AND estado = 0 );

       SET apartados_vigentes = (SELECT COUNT(*) AS apartados_vigentes FROM apartado

	   WHERE DATE_FORMAT(fecha_apartado,'%m-%Y') = p_date AND estado = 1);

	   SET apartados_saldados = (SELECT COUNT(*) AS apartados_vigentes FROM apartado

	   WHERE DATE_FORMAT(fecha_apartado,'%m-%Y') = p_date AND estado = 2);



       SELECT apartados_anuladas,apartados_vigentes,apartados_saldados;



           END IF;



   ELSEIF (p_criterio = 'FECHAS') THEN



       IF (p_date = '' AND p_date2 = '') THEN



       SET apartados_anuladas = (SELECT COUNT(*) AS apartados_anuladas

       FROM apartado WHERE estado = 0 AND DATE_FORMAT(fecha_apartado,'%m-%Y') =  MONTH(CURDATE()));

       SET apartados_vigentes = (SELECT COUNT(*) AS apartados_vigentes

	   FROM apartado WHERE estado = 1 AND DATE_FORMAT(fecha_apartado,'%m-%Y') = MONTH(CURDATE()));

	   SET apartados_saldados = (SELECT COUNT(*) AS apartados_vigentes

	   FROM apartado WHERE estado = 2 AND DATE_FORMAT(fecha_apartado,'%m-%Y') = MONTH(CURDATE()));



		SELECT apartados_anuladas,apartados_vigentes,apartados_saldados;



     ELSE



       SET apartados_anuladas = (SELECT COUNT(*) AS apartados_anuladas FROM apartado

       WHERE estado = 0 AND DATE_FORMAT(fecha_apartado,'%Y-%m-%d') BETWEEN p_date AND p_date2);

       SET apartados_vigentes = (SELECT COUNT(*) AS apartados_vigentes FROM apartado

       WHERE estado = 1 AND DATE_FORMAT(fecha_apartado,'%Y-%m-%d') BETWEEN p_date AND p_date2);

	   SET apartados_saldados = (SELECT COUNT(*) AS apartados_vigentes FROM apartado

       WHERE estado = 2 AND DATE_FORMAT(fecha_apartado,'%Y-%m-%d') BETWEEN p_date AND p_date2);



       SELECT apartados_anuladas,apartados_vigentes,apartados_saldados;



           END IF;



   ELSEIF (p_criterio = 'HOY') THEN



     SET apartados_anuladas = (SELECT COUNT(*) AS apartados_anuladas

     FROM apartado WHERE estado = 0 AND DATE_FORMAT(fecha_apartado,'%Y-%m-%d') =  CURDATE());

     SET apartados_vigentes = (SELECT COUNT(*) AS apartados_vigentes

     FROM apartado WHERE estado = 1 AND DATE_FORMAT(fecha_apartado,'%Y-%m-%d') =  CURDATE());

     SET apartados_saldados = (SELECT COUNT(*) AS apartados_vigentes

     FROM apartado WHERE estado = 2 AND DATE_FORMAT(fecha_apartado,'%Y-%m-%d') =  CURDATE());





     SELECT apartados_anuladas,apartados_vigentes,apartados_saldados;



 END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_count_compras` (IN `p_criterio` VARCHAR(10), IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10))   BEGIN



        DECLARE compras_anuladas INT;

        DECLARE compras_vigentes INT;

        DECLARE compras_contado INT;

        DECLARE compras_credito INT;





		IF (p_criterio = 'MES') THEN



			IF (p_date = '') THEN



				SET compras_anuladas = (SELECT COUNT(*) AS compras_anuladas

                FROM compra WHERE estado = 0 AND DATE_FORMAT(fecha_compra,'%m-%Y') =  MONTH(CURDATE()));

				SET compras_vigentes = (SELECT COUNT(*) AS compras_vigentes

                FROM compra WHERE estado = 1 AND DATE_FORMAT(fecha_compra,'%m-%Y') = MONTH(CURDATE()));

				SET compras_contado = (SELECT COUNT(*) AS compras_vigentes

                FROM compra WHERE tipo_pago = 1 AND  DATE_FORMAT(fecha_compra,'%m-%Y') = MONTH(CURDATE()));

				SET compras_credito = (SELECT COUNT(*) AS compras_vigentes

                FROM compra WHERE tipo_pago = 2 AND  DATE_FORMAT(fecha_compra,'%m-%Y') = MONTH(CURDATE()));



                SELECT compras_anuladas,compras_vigentes,compras_contado,compras_credito;



			ELSE



				SET compras_anuladas = (SELECT COUNT(*) AS compras_anuladas FROM compra

                WHERE DATE_FORMAT(fecha_compra,'%m-%Y') = p_date AND estado = 0 );

				SET compras_vigentes = (SELECT COUNT(*) AS compras_vigentes FROM compra

                WHERE DATE_FORMAT(fecha_compra,'%m-%Y') = p_date AND estado = 1);

				SET compras_contado = (SELECT COUNT(*) AS compras_vigentes FROM compra

                WHERE DATE_FORMAT(fecha_compra,'%m-%Y') = p_date AND tipo_pago = 1);

				SET compras_credito = (SELECT COUNT(*) AS compras_vigentes FROM compra

                WHERE DATE_FORMAT(fecha_compra,'%m-%Y') = p_date AND tipo_pago = 2);



				SELECT compras_anuladas,compras_vigentes,compras_contado,compras_credito;



            END IF;




		ELSEIF (p_criterio = 'FECHAS') THEN



        IF (p_date = '' AND p_date2 = '') THEN



				SET compras_anuladas = (SELECT COUNT(*) AS compras_anuladas

                FROM compra WHERE estado = 0 AND DATE_FORMAT(fecha_compra,'%m-%Y') =  MONTH(CURDATE()));

				SET compras_vigentes = (SELECT COUNT(*) AS compras_vigentes

                FROM compra WHERE estado = 1 AND DATE_FORMAT(fecha_compra,'%m-%Y') = MONTH(CURDATE()));

				SET compras_contado = (SELECT COUNT(*) AS compras_vigentes

                FROM compra WHERE tipo_pago = 1 AND  DATE_FORMAT(fecha_compra,'%m-%Y') = MONTH(CURDATE()));

				SET compras_credito = (SELECT COUNT(*) AS compras_vigentes

                FROM compra WHERE tipo_pago = 2 AND  DATE_FORMAT(fecha_compra,'%m-%Y') = MONTH(CURDATE()));



                SELECT compras_anuladas,compras_vigentes,compras_contado,compras_credito;



			ELSE



				SET compras_anuladas = (SELECT COUNT(*) AS compras_anuladas FROM compra

				WHERE estado = 0 AND DATE_FORMAT(fecha_compra,'%Y-%m-%d') BETWEEN p_date AND p_date2);

				SET compras_vigentes = (SELECT COUNT(*) AS compras_vigentes FROM compra

				WHERE estado = 1 AND DATE_FORMAT(fecha_compra,'%Y-%m-%d') BETWEEN p_date AND p_date2);

				SET compras_contado = (SELECT COUNT(*) AS compras_vigentes FROM compra

				WHERE tipo_pago = 1 AND DATE_FORMAT(fecha_compra,'%Y-%m-%d') BETWEEN p_date AND p_date2);

				SET compras_credito = (SELECT COUNT(*) AS compras_vigentes FROM compra

				WHERE tipo_pago = 2 AND DATE_FORMAT(fecha_compra,'%Y-%m-%d') BETWEEN p_date AND p_date2);



				SELECT compras_anuladas,compras_vigentes,compras_contado,compras_credito;



            END IF;



	END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_count_cotizaciones` (IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10))   BEGIN



		IF (p_date = '' AND p_date2 = '') THEN



			SELECT COUNT(*) AS total_cotizaciones FROM cotizacion;



		ELSE



			SELECT COUNT(*) AS total_cotizaciones

            FROM cotizacion WHERE fecha_cotizacion

            BETWEEN p_date AND p_date2;



		END IF;





END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_count_creditos` ()   BEGIN



    DECLARE count_pendientes int;

    DECLARE count_pagados int;



	SET count_pendientes = (SELECT COUNT(*) AS creditos_pendientes FROM credito WHERE estado = 0);

    SET count_pagados = (SELECT COUNT(*) AS creditos_pagados FROM credito WHERE estado = 1);



    SELECT count_pendientes,count_pagados;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_count_ordenes` (IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10))   BEGIN



 IF (p_date = '' AND p_date2 = '') THEN

		SELECT COUNT(*) as total_ordenes FROM view_taller ORDER BY fecha_ingreso DESC;

	ELSE

		 SELECT COUNT(*) as total_ordenes  FROM view_taller WHERE DATE_FORMAT(fecha_ingreso,'%Y-%m-%d') BETWEEN p_date AND p_date2

		 ORDER BY  DATE_FORMAT(fecha_ingreso,'%Y-%m-%d') DESC;

    END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_count_ventas` (IN `p_criterio` VARCHAR(10), IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10))   BEGIN



        DECLARE ventas_anuladas INT;

        DECLARE ventas_vigentes INT;

        DECLARE ventas_contado INT;

        DECLARE ventas_credito INT;





		IF (p_criterio = 'MES') THEN



			IF (p_date = '') THEN



				SET ventas_anuladas = (SELECT COUNT(*) AS ventas_anuladas

                FROM venta WHERE estado = 0 AND DATE_FORMAT(fecha_venta,'%m-%Y') =  MONTH(CURDATE()));

				SET ventas_vigentes = (SELECT COUNT(*) AS ventas_vigentes

                FROM venta WHERE estado = 1 AND DATE_FORMAT(fecha_venta,'%m-%Y') = MONTH(CURDATE()));

				SET ventas_contado = (SELECT COUNT(*) AS ventas_vigentes

                FROM venta WHERE estado = 1 AND  DATE_FORMAT(fecha_venta,'%m-%Y') = MONTH(CURDATE()));

				SET ventas_credito = (SELECT COUNT(*) AS ventas_vigentes

                FROM venta WHERE estado = 2 AND  DATE_FORMAT(fecha_venta,'%m-%Y') = MONTH(CURDATE()));



                SELECT ventas_anuladas,ventas_vigentes,ventas_contado,ventas_credito;



			ELSE



				SET ventas_anuladas = (SELECT COUNT(*) AS ventas_anuladas FROM venta

                WHERE DATE_FORMAT(fecha_venta,'%m-%Y') = p_date AND estado = 0 );

				SET ventas_vigentes = (SELECT COUNT(*) AS ventas_vigentes FROM venta

                WHERE DATE_FORMAT(fecha_venta,'%m-%Y') = p_date AND estado = 1);

				SET ventas_contado = (SELECT COUNT(*) AS ventas_vigentes FROM venta

                WHERE DATE_FORMAT(fecha_venta,'%m-%Y') = p_date AND estado = 1);

				SET ventas_credito = (SELECT COUNT(*) AS ventas_vigentes FROM venta

                WHERE DATE_FORMAT(fecha_venta,'%m-%Y') = p_date AND estado = 2);



				SELECT ventas_anuladas,ventas_vigentes,ventas_contado,ventas_credito;



            END IF;



		ELSEIF (p_criterio = 'FECHAS') THEN



        IF (p_date = '' AND p_date2 = '') THEN



				SET ventas_anuladas = (SELECT COUNT(*) AS ventas_anuladas

                FROM venta WHERE estado = 0 AND DATE_FORMAT(fecha_venta,'%m-%Y') =  MONTH(CURDATE()));

				SET ventas_vigentes = (SELECT COUNT(*) AS ventas_vigentes

                FROM venta WHERE estado = 1 AND DATE_FORMAT(fecha_venta,'%m-%Y') = MONTH(CURDATE()));

				SET ventas_contado = (SELECT COUNT(*) AS ventas_vigentes

                FROM venta WHERE estado = 1 AND  DATE_FORMAT(fecha_venta,'%m-%Y') = MONTH(CURDATE()));

				SET ventas_credito = (SELECT COUNT(*) AS ventas_vigentes

                FROM venta WHERE estado = 2 AND  DATE_FORMAT(fecha_venta,'%m-%Y') = MONTH(CURDATE()));



                SELECT ventas_anuladas,ventas_vigentes,ventas_contado,ventas_credito;



			ELSE



				SET ventas_anuladas = (SELECT COUNT(*) AS ventas_anuladas FROM venta

				WHERE estado = 0 AND DATE_FORMAT(fecha_venta,'%Y-%m-%d') BETWEEN p_date AND p_date2);

				SET ventas_vigentes = (SELECT COUNT(*) AS ventas_vigentes FROM venta

				WHERE estado = 1 AND DATE_FORMAT(fecha_venta,'%Y-%m-%d') BETWEEN p_date AND p_date2);

				SET ventas_contado = (SELECT COUNT(*) AS ventas_vigentes FROM venta

				WHERE estado = 1 AND DATE_FORMAT(fecha_venta,'%Y-%m-%d') BETWEEN p_date AND p_date2);

				SET ventas_credito = (SELECT COUNT(*) AS ventas_vigentes FROM venta

				WHERE estado = 2 AND DATE_FORMAT(fecha_venta,'%Y-%m-%d') BETWEEN p_date AND p_date2);



				SELECT ventas_anuladas,ventas_vigentes,ventas_contado,ventas_credito;



            END IF;



		ELSEIF (p_criterio = 'HOY') THEN



			SET ventas_anuladas = (SELECT COUNT(*) AS ventas_anuladas

			FROM venta WHERE estado = 0 AND DATE_FORMAT(fecha_venta,'%Y-%m-%d') =  CURDATE());

			SET ventas_vigentes = (SELECT COUNT(*) AS ventas_vigentes

			FROM venta WHERE estado = 1 AND DATE_FORMAT(fecha_venta,'%Y-%m-%d') =  CURDATE());

			SET ventas_contado = (SELECT COUNT(*) AS ventas_vigentes

			FROM venta WHERE estado = 1 AND DATE_FORMAT(fecha_venta,'%Y-%m-%d') =  CURDATE());

			SET ventas_credito = (SELECT COUNT(*) AS ventas_vigentes

			FROM venta WHERE estado = 2 AND DATE_FORMAT(fecha_venta,'%Y-%m-%d') =  CURDATE());



			SELECT ventas_anuladas,ventas_vigentes,ventas_contado,ventas_credito;



	END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_abono` (IN `p_idabono` INT(11))   BEGIN



	DECLARE p_monto_abono DECIMAL(13,2);

    DECLARE p_idcredito INT;

    DECLARE p_monto_abonado DECIMAL(13,2);

    DECLARE p_monto_restante DECIMAL(13,2);



    SET p_monto_abono = (SELECT monto_abono FROM abono WHERE idabono = p_idabono);

    SET p_idcredito = (SELECT idcredito FROM view_abonos WHERE idabono = p_idabono);

    SET p_monto_abonado = (SELECT monto_abonado FROM credito WHERE idcredito = p_idcredito);

    SET p_monto_restante = (SELECT monto_restante FROM credito WHERE idcredito = p_idcredito);



    IF p_monto_restante = 0 THEN



		UPDATE credito SET

        estado = 0,

        monto_restante = p_monto_abono,

        monto_abonado = monto_abonado - p_monto_abono

        WHERE idcredito = p_idcredito;



    ELSEIF p_monto_restante > 0 THEN

		UPDATE credito SET

        monto_restante = monto_restante + p_monto_abono,

        monto_abonado = monto_abonado - p_monto_abono

        WHERE idcredito = p_idcredito;

    END IF;



	DELETE FROM `abono`

	WHERE `idabono` = p_idabono;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_cotizacion` (IN `p_idcotizacion` INT(11))   BEGIN

DELETE FROM `cotizacion`

WHERE `idcotizacion` = p_idcotizacion;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_ordentaller` (IN `p_idorden` INT(11))   BEGIN

	DELETE FROM detalle_ordentaller
    WHERE idorden = p_idorden;

	DELETE FROM `ordentaller`
	WHERE `idorden` = p_idorden;
    


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_perecedero` (IN `p_fecha_vencimiento` DATE, IN `p_idproducto` INT(11))   BEGIN

	DELETE FROM `perecedero` WHERE `idproducto` =  p_idproducto

    AND `fecha_vencimiento` = p_fecha_vencimiento;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_descontar_perecedero` (IN `p_idproducto` INT(11), IN `p_cantidad` DECIMAL(13,2), IN `p_fecha_vencimiento` DATE)   BEGIN



    DECLARE p_cantidad_perecedero DECIMAL(13,2);

    DECLARE p_resta DECIMAL(13,2);



	SET p_cantidad_perecedero = (SELECT cantidad_perecedero FROM perecedero WHERE

    idproducto = p_idproducto AND cantidad_perecedero > 0.00

    AND fecha_vencimiento = p_fecha_vencimiento);



    SET p_resta = p_cantidad_perecedero - p_cantidad;



    IF p_resta = 0 THEN



        UPDATE perecedero SET

		cantidad_perecedero = 0.00,

        estado = 2

        WHERE idproducto = p_idproducto AND fecha_vencimiento = p_fecha_vencimiento;



     ELSE



		UPDATE perecedero SET

		cantidad_perecedero = p_resta

        WHERE idproducto = p_idproducto AND fecha_vencimiento = p_fecha_vencimiento;



    END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_detalle_imprimir_ticket_apartado` (IN `p_idapartado` INT(11))   BEGIN



		DECLARE p_idmax int;

				SET p_idmax = (SELECT MAX(idapartado) FROM apartado);





		IF (p_idapartado = '') THEN



		SELECT cantidad, substring(nombre_producto,1,12) as descripcion,precio_unitario,

				if(producto_exento = '1', CONCAT(importe,'E'), CONCAT(importe,'G')) as importe

				FROM view_apartados

				WHERE idapartado = p_idmax;



				ELSE



		SELECT cantidad, substring(nombre_producto,1,12) as descripcion,precio_unitario,

				if(producto_exento = '1', CONCAT(importe,'E'), CONCAT(importe,'G')) as importe

				FROM view_apartados

				WHERE idapartado = p_idapartado;



		END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_detalle_imprimir_ticket_venta` (IN `p_idventa` INT(11))   BEGIN
		DECLARE p_idmax int;
        SET p_idmax = (SELECT MAX(idventa) FROM venta);
		IF (p_idventa = '') THEN
        SELECT cantidad, nombre_producto as descripcion,precio_unitario,
        if(producto_exento = '1', CONCAT((precio_unitario*cantidad),'E'), CONCAT((precio_unitario*cantidad),'G')) as importe
        FROM view_ventas
        WHERE idventa = p_idmax;
        ELSE
		SELECT cantidad, nombre_producto as descripcion,precio_unitario,
        if(producto_exento = '1', CONCAT((precio_unitario*cantidad),'E'), CONCAT((precio_unitario*cantidad),'G')) as importe
        FROM view_ventas
        WHERE idventa = p_idventa;
		END IF;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_devolver_productos_apartados` ()   BEGIN

		

		DECLARE i int;

        DECLARE temp_id INT;

        DECLARE p_count INT;

        DECLARE p_idmax INT;

        

        SET p_count = (SELECT COUNT(*) FROM apartado WHERE `estado` = 1

		AND fecha_limite_retiro < CURDATE());

        SET i = 0;

        SET temp_id = 0;

        

        WHILE (i < p_count) DO

        

			DROP TABLE IF EXISTS temporal_apartados;

			CREATE TEMPORARY TABLE IF NOT EXISTS temporal_apartados

			SELECT idapartado FROM apartado WHERE `estado` = 1

			AND fecha_limite_retiro < CURDATE();

        

			SET p_idmax = (SELECT max(idapartado) FROM temporal_apartados);

			

            IF(temp_id != p_idmax) THEN

            

				SET temp_id = (p_idmax);

				CALL sp_anular_apartado(temp_id);

                

			END IF;

            

			SET i = i + 1;

            

        END WHILE;

        

	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_EliminsrDetalleOrden` (IN `p_iddetalle` INT, IN `p_idproducto` INT, IN `p_cantidad` INT)   BEGIN

DELETE FROM detalle_ordentaller 
WHERE idDetalle = p_iddetalle;

UPDATE producto
SET stock = stock + p_cantidad
WHERE idproducto = p_idproducto;

SELECT ROW_COUNT() AS filas_actualizadas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_fechas_vencimiento` (IN `p_idproducto` INT(11))   BEGIN



   SELECT cantidad_perecedero, DATE_FORMAT(fecha_vencimiento,'%d/%m/%Y') as fecha_vencimiento FROM perecedero

   WHERE idproducto = p_idproducto

   AND estado = 1 ORDER by fecha_vencimiento ASC;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_finalizar_venta` (IN `p_idventa` INT(11))   BEGIN



	DECLARE p_total DECIMAL(13,2);

    DECLARE p_descr_salida varchar(150);

    DECLARE p_tipo_comprobante tinyint(1);

    DECLARE p_numero_comprobante int(11);



    SET p_total = (SELECT total FROM venta WHERE idventa = p_idventa);

    SET p_tipo_comprobante = (SELECT tipo_comprobante FROM venta WHERE idventa = p_idventa);

    SET p_numero_comprobante = (SELECT numero_comprobante FROM venta WHERE idventa = p_idventa);



    IF p_tipo_comprobante = '1' THEN

		SET p_descr_salida = (CONCAT('POR VENTA',' ','TICKET', ' # ',p_numero_comprobante));

	ELSEIF p_tipo_comprobante = '2' THEN

		SET p_descr_salida = (CONCAT('POR VENTA',' ','FACTURA', ' # ',p_numero_comprobante));

	ELSEIF p_tipo_comprobante = '3' THEN

		SET p_descr_salida = (CONCAT('POR VENTA',' ','BOLETA', ' # ',p_numero_comprobante));

    END IF;



	INSERT INTO `salida`(`mes_inventario`,`fecha_salida`, `descripcion_salida`, `cantidad_salida`,

	`precio_unitario_salida`, `costo_total_salida`, `idproducto`)

	SELECT DATE_FORMAT(CURDATE(),'%Y-%m'),NOW(),p_descr_salida,cantidad,precio_unitario,(cantidad*precio_unitario),idproducto

	FROM detalleventa WHERE idventa = p_idventa;





	UPDATE inventario t2

	JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

	SET t2.saldo_final = t2.saldo_final - t1.cantidad,

	t2.salidas = t2.salidas + t1.cantidad

	WHERE t1.idventa = p_idventa AND t2.idproducto = t1.idproducto

	AND t2.fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

	AND t2.fecha_cierre = LAST_DAY(CURDATE());



    UPDATE perecedero t2

    JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

    SET t2.cantidad_perecedero = t2.cantidad_perecedero - t1.cantidad

    WHERE t2.idproducto = t1.idproducto AND t2.fecha_vencimiento = t1.fecha_vence;



    UPDATE producto t2

    JOIN detalleventa t1 ON t1.idproducto = t2.idproducto

    SET t2.stock = t2.stock - t1.cantidad

    WHERE t2.idproducto = t1.idproducto;



    UPDATE venta SET

    estado = 1

    WHERE idventa = p_idventa;



	CALL sp_insert_caja_venta(p_total);





END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_historico_caja` (IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10))   BEGIN

    IF (p_date = '' AND p_date2 = '') THEN

		SELECT * FROM caja ORDER BY fecha_apertura DESC;

	ELSE

		 SELECT * FROM caja WHERE fecha_apertura BETWEEN p_date AND p_date2

		 ORDER BY fecha_apertura DESC;

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_imprimir_factura` (IN `p_idventa` INT)   BEGIN

        DECLARE p_idmax int;

        DECLARE p_tipo_comprobante tinyint(1);

        DECLARE p_idcliente int;

        DECLARE p_idparametro int;

        DECLARE p_empresa varchar(150);

        DECLARE p_propietario varchar(150);

        DECLARE p_direccion varchar(200);

        DECLARE p_numero_nit varchar(70);

        DECLARE p_numero_nrc varchar(70);

        DECLARE p_fecha_resolucion datetime;

        DECLARE p_numero_resolucion varchar(80);

        DECLARE p_serie varchar(175);

        DECLARE p_subtotal DECIMAL(13,2);

        DECLARE p_exento DECIMAL(13,2);

        DECLARE p_descuento DECIMAL(13,2);

        DECLARE p_total DECIMAL(13,2);

        DECLARE p_numero_productos DECIMAL(13,2);

        DECLARE p_numero_comprobante INT;

        DECLARE p_empleado varchar(181);

        DECLARE p_numero_venta varchar(175);

        DECLARE p_fecha_venta datetime;

        DECLARE p_moneda varchar(35);

        DECLARE p_idcurrency int;

        DECLARE p_estado tinyint(1);





         DECLARE p_tipo_pago varchar(75);

		 DECLARE p_pago_efectivo DECIMAL(13,2);

         DECLARE p_pago_tarjeta DECIMAL(13,2);

         DECLARE p_numero_tarjeta varchar(16);

         DECLARE p_tarjeta_habiente varchar(90);

         DECLARE p_cambio DECIMAL(13,2);



        SET p_idmax = (SELECT MAX(idventa) FROM venta);

        SET p_idparametro = (SELECT MAX(idparametro) FROM parametro);

        SET p_idcurrency = (SELECT idcurrency FROM parametro WHERE idparametro = p_idparametro);

        SET p_empresa = (SELECT nombre_empresa FROM parametro);

        SET p_propietario = (SELECT propietario FROM parametro);

        SET p_direccion = (SELECT direccion_empresa FROM parametro);

        SET p_numero_nit = (SELECT numero_nit FROM parametro);

        SET p_numero_nrc = (SELECT numero_nrc FROM parametro);

        SET p_fecha_resolucion = (SELECT fecha_resolucion FROM tiraje_comprobante WHERE idcomprobante = 1);

        SET p_numero_resolucion = (SELECT numero_resolucion FROM tiraje_comprobante WHERE idcomprobante = 1);

        SET p_serie = (SELECT serie FROM tiraje_comprobante WHERE idcomprobante = 1);

        SET p_moneda = (SELECT CurrencyName	FROM currency WHERE idcurrency = p_idcurrency);













		IF (p_idventa = '') THEN



        SET p_tipo_comprobante = (SELECT tipo_comprobante FROM venta WHERE idventa = p_idmax);

         SET p_idcliente = (SELECT idcliente FROM venta WHERE idventa = p_idmax);

		SET p_subtotal = (SELECT (sumas + iva) as subtotal FROM venta WHERE idventa = p_idmax);

		SET p_exento = (SELECT exento FROM venta WHERE idventa = p_idmax);

		SET p_descuento = (SELECT descuento FROM venta WHERE idventa = p_idmax);

        SET p_total = (SELECT total FROM venta WHERE idventa = p_idmax);

        SET p_numero_productos = (SELECT SUM(cantidad) FROM detalleventa WHERE idventa = p_idmax);

        SET p_numero_comprobante = (SELECT numero_comprobante FROM venta WHERE idventa = p_idmax);

        SET p_empleado = (SELECT empleado FROM view_ventas WHERE idventa = p_idmax GROUP BY empleado);

        SET p_numero_venta = (SELECT numero_venta FROM venta WHERE idventa = p_idmax);

		SET p_fecha_venta = (SELECT fecha_venta FROM venta WHERE idventa = p_idmax);

		SET p_tipo_pago  = (SELECT tipo_pago FROM venta WHERE idventa = p_idmax);

		SET p_pago_efectivo  = (SELECT pago_efectivo FROM venta WHERE idventa = p_idmax);

        SET p_pago_tarjeta  = (SELECT pago_tarjeta FROM venta WHERE idventa = p_idmax);

        SET p_numero_tarjeta  = (SELECT numero_tarjeta FROM venta WHERE idventa = p_idmax);

        SET p_tarjeta_habiente  = (SELECT tarjeta_habiente FROM venta WHERE idventa = p_idmax);

        SET p_cambio = (SELECT cambio FROM venta WHERE idventa = p_idmax);

        SET p_estado = (SELECT estado FROM venta WHERE idventa = p_idmax);



        SELECT p_idcliente, p_tipo_comprobante,p_empresa, p_propietario, p_direccion, p_numero_nit , p_numero_nrc,

        DATE_FORMAT(p_fecha_resolucion,'%d/%m/%Y %k:%i %p')  as p_fecha_resolucion,p_numero_resolucion,

        p_serie, p_numero_comprobante,  p_subtotal, p_exento, p_descuento, p_total, p_numero_productos,

		p_empleado,DATE_FORMAT(p_fecha_venta,'%d/%m/%Y %k:%i %p') as p_fecha_venta ,p_numero_venta,

        p_tipo_pago, p_pago_efectivo, p_pago_tarjeta, p_numero_tarjeta, p_tarjeta_habiente, p_cambio,

        p_moneda,p_estado;



        ELSE



        SET p_tipo_comprobante = (SELECT tipo_comprobante FROM venta WHERE idventa = p_idventa);

        SET p_idcliente = (SELECT idcliente FROM venta WHERE idventa = p_idventa);

		SET p_subtotal = (SELECT (sumas + iva) as subtotal FROM venta WHERE idventa = p_idventa);

		SET p_exento = (SELECT exento FROM venta WHERE idventa = p_idventa);

		SET p_descuento = (SELECT descuento FROM venta WHERE idventa = p_idventa);

        SET p_total = (SELECT total FROM venta WHERE idventa = p_idventa);

        SET p_numero_productos = (SELECT SUM(cantidad) FROM detalleventa WHERE idventa = p_idventa);

        SET p_numero_comprobante = (SELECT numero_comprobante FROM venta WHERE idventa = p_idventa);

        SET p_empleado = (SELECT empleado FROM view_ventas WHERE idventa =  p_idventa  GROUP BY empleado);

		SET p_numero_venta = (SELECT numero_venta FROM venta WHERE idventa = p_idventa);

		SET p_fecha_venta = (SELECT fecha_venta FROM venta WHERE idventa =  p_idventa);

		SET p_tipo_pago  = (SELECT tipo_pago FROM venta WHERE idventa = p_idventa);

		SET p_pago_efectivo  = (SELECT pago_efectivo FROM venta WHERE idventa =  p_idventa);

        SET p_pago_tarjeta  = (SELECT pago_tarjeta FROM venta WHERE idventa =  p_idventa);

        SET p_numero_tarjeta  = (SELECT numero_tarjeta FROM venta WHERE idventa =  p_idventa);

        SET p_tarjeta_habiente  = (SELECT tarjeta_habiente FROM venta WHERE idventa =  p_idventa);

        SET p_cambio = (SELECT cambio FROM venta WHERE idventa =  p_idventa);

        SET p_estado = (SELECT estado FROM venta WHERE idventa = p_idventa);



        SELECT p_idcliente,p_tipo_comprobante,p_empresa, p_propietario, p_direccion, p_numero_nit , p_numero_nrc,

        DATE_FORMAT(p_fecha_resolucion,'%d/%m/%Y %k:%i %p')  as p_fecha_resolucion,p_numero_resolucion,

        p_serie, p_numero_comprobante,  p_subtotal, p_exento, p_descuento, p_total, p_numero_productos,

		p_empleado,DATE_FORMAT(p_fecha_venta,'%d/%m/%Y %k:%i %p') as p_fecha_venta,p_numero_venta,

        p_tipo_pago, p_pago_efectivo, p_pago_tarjeta, p_numero_tarjeta, p_tarjeta_habiente, p_cambio,

        p_moneda,p_estado;



		END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_imprimir_ticket` (IN `p_idventa` INT(11))   BEGIN

        DECLARE p_idmax int;

        DECLARE p_tipo_comprobante tinyint(1);

        DECLARE p_idcliente int;

        DECLARE p_idparametro int;

        DECLARE p_empresa varchar(150);

        DECLARE p_propietario varchar(150);

        DECLARE p_direccion varchar(200);

        DECLARE p_numero_nit varchar(70);

        DECLARE p_numero_nrc varchar(70);

        DECLARE p_fecha_resolucion datetime;

        DECLARE p_numero_resolucion varchar(80);

        DECLARE p_serie varchar(175);

        DECLARE p_subtotal DECIMAL(13,2);

        DECLARE p_exento DECIMAL(13,2);

        DECLARE p_descuento DECIMAL(13,2);

        DECLARE p_total DECIMAL(13,2);

        DECLARE p_numero_productos DECIMAL(13,2);

        DECLARE p_numero_comprobante INT;

        DECLARE p_empleado varchar(181);

        DECLARE p_numero_venta varchar(175);

        DECLARE p_fecha_venta datetime;

        DECLARE p_moneda varchar(35);

        DECLARE p_idcurrency int;

        DECLARE p_estado tinyint(1);

         DECLARE p_tipo_pago varchar(75);

		 DECLARE p_pago_efectivo DECIMAL(13,2);

         DECLARE p_pago_tarjeta DECIMAL(13,2);

         DECLARE p_numero_tarjeta varchar(16);

         DECLARE p_tarjeta_habiente varchar(90);

         DECLARE p_cambio DECIMAL(13,2);
         
		 DECLARE p_iva DECIMAL(13,2);



        SET p_idmax = (SELECT MAX(idventa) FROM venta);

        SET p_idparametro = (SELECT MAX(idparametro) FROM parametro);

        SET p_idcurrency = (SELECT idcurrency FROM parametro WHERE idparametro = p_idparametro);

        SET p_empresa = (SELECT nombre_empresa FROM parametro);

        SET p_propietario = (SELECT propietario FROM parametro);

        SET p_direccion = (SELECT direccion_empresa FROM parametro);

        SET p_numero_nit = (SELECT numero_nit FROM parametro);

        SET p_numero_nrc = (SELECT numero_nrc FROM parametro);

        SET p_fecha_resolucion = (SELECT fecha_resolucion FROM tiraje_comprobante WHERE idcomprobante = 1);

        SET p_numero_resolucion = (SELECT numero_resolucion FROM tiraje_comprobante WHERE idcomprobante = 1);

        SET p_serie = (SELECT serie FROM tiraje_comprobante WHERE idcomprobante = 1);

        SET p_moneda = (SELECT CurrencyName	FROM currency WHERE idcurrency = p_idcurrency);
        



		IF (p_idventa = '') THEN



        SET p_tipo_comprobante = (SELECT tipo_comprobante FROM venta WHERE idventa = p_idmax);

         SET p_idcliente = (SELECT idcliente FROM venta WHERE idventa = p_idmax);

		SET p_subtotal = (SELECT sumas as subtotal FROM venta WHERE idventa = p_idmax);

		SET p_exento = (SELECT exento FROM venta WHERE idventa = p_idmax);

		SET p_descuento = (SELECT descuento FROM venta WHERE idventa = p_idmax);

        SET p_total = (SELECT total FROM venta WHERE idventa = p_idmax);

        SET p_numero_productos = (SELECT SUM(cantidad) FROM detalleventa WHERE idventa = p_idmax);

        SET p_numero_comprobante = (SELECT numero_comprobante FROM venta WHERE idventa = p_idmax);

        SET p_empleado = (SELECT empleado FROM view_ventas WHERE idventa = p_idmax GROUP BY empleado);

        SET p_numero_venta = (SELECT numero_venta FROM venta WHERE idventa = p_idmax);

		SET p_fecha_venta = (SELECT fecha_venta FROM venta WHERE idventa = p_idmax);

		SET p_tipo_pago  = (SELECT tipo_pago FROM venta WHERE idventa = p_idmax);

		SET p_pago_efectivo  = (SELECT pago_efectivo FROM venta WHERE idventa = p_idmax);

        SET p_pago_tarjeta  = (SELECT pago_tarjeta FROM venta WHERE idventa = p_idmax);

        SET p_numero_tarjeta  = (SELECT numero_tarjeta FROM venta WHERE idventa = p_idmax);

        SET p_tarjeta_habiente  = (SELECT tarjeta_habiente FROM venta WHERE idventa = p_idmax);

        SET p_cambio = (SELECT cambio FROM venta WHERE idventa = p_idmax);

        SET p_estado = (SELECT estado FROM venta WHERE idventa = p_idmax);
        
        SET p_iva = (SELECT iva FROM venta WHERE idventa = p_idmax);



        SELECT p_idcliente, p_tipo_comprobante,p_empresa, p_propietario, p_direccion, p_numero_nit , p_numero_nrc,

        DATE_FORMAT(p_fecha_resolucion,'%d/%m/%Y %k:%i %p')  as p_fecha_resolucion,p_numero_resolucion,

        p_serie, p_numero_comprobante,  p_subtotal, p_exento, p_descuento, p_total, p_numero_productos,

		p_empleado,DATE_FORMAT(p_fecha_venta,'%d/%m/%Y %k:%i %p') as p_fecha_venta ,p_numero_venta,

        p_tipo_pago, p_pago_efectivo, p_pago_tarjeta, p_numero_tarjeta, p_tarjeta_habiente, p_cambio,

        p_moneda,p_estado,p_iva;



        ELSE



        SET p_tipo_comprobante = (SELECT tipo_comprobante FROM venta WHERE idventa = p_idventa);

        SET p_idcliente = (SELECT idcliente FROM venta WHERE idventa = p_idventa);

		SET p_subtotal = (SELECT sumas as subtotal FROM venta WHERE idventa = p_idventa);

		SET p_exento = (SELECT exento FROM venta WHERE idventa = p_idventa);

		SET p_descuento = (SELECT descuento FROM venta WHERE idventa = p_idventa);

        SET p_total = (SELECT total FROM venta WHERE idventa = p_idventa);

        SET p_numero_productos = (SELECT SUM(cantidad) FROM detalleventa WHERE idventa = p_idventa);

        SET p_numero_comprobante = (SELECT numero_comprobante FROM venta WHERE idventa = p_idventa);

        SET p_empleado = (SELECT empleado FROM view_ventas WHERE idventa =  p_idventa  GROUP BY empleado);

		SET p_numero_venta = (SELECT numero_venta FROM venta WHERE idventa = p_idventa);

		SET p_fecha_venta = (SELECT fecha_venta FROM venta WHERE idventa =  p_idventa);

		SET p_tipo_pago  = (SELECT tipo_pago FROM venta WHERE idventa = p_idventa);

		SET p_pago_efectivo  = (SELECT pago_efectivo FROM venta WHERE idventa =  p_idventa);

        SET p_pago_tarjeta  = (SELECT pago_tarjeta FROM venta WHERE idventa =  p_idventa);

        SET p_numero_tarjeta  = (SELECT numero_tarjeta FROM venta WHERE idventa =  p_idventa);

        SET p_tarjeta_habiente  = (SELECT tarjeta_habiente FROM venta WHERE idventa =  p_idventa);

        SET p_cambio = (SELECT cambio FROM venta WHERE idventa =  p_idventa);

        SET p_estado = (SELECT estado FROM venta WHERE idventa = p_idventa);
        
        SET p_iva = (SELECT iva FROM venta WHERE idventa = p_idventa);



        SELECT p_idcliente,p_tipo_comprobante,p_empresa, p_propietario, p_direccion, p_numero_nit , p_numero_nrc,

        DATE_FORMAT(p_fecha_resolucion,'%d/%m/%Y %k:%i %p')  as p_fecha_resolucion,p_numero_resolucion,

        p_serie, p_numero_comprobante,  p_subtotal, p_exento, p_descuento, p_total, p_numero_productos,

		p_empleado,DATE_FORMAT(p_fecha_venta,'%d/%m/%Y %k:%i %p') as p_fecha_venta,p_numero_venta,

        p_tipo_pago, p_pago_efectivo, p_pago_tarjeta, p_numero_tarjeta, p_tarjeta_habiente, p_cambio,

        p_moneda,p_estado,p_iva;



		END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_imprimir_ticket_abono` (IN `p_idabono` INT(11))   BEGIN





        DECLARE p_idmax int;

        DECLARE p_idparametro int;

        DECLARE p_empresa varchar(150);

        DECLARE p_propietario varchar(150);

        DECLARE p_direccion varchar(200);

        DECLARE p_numero_nit varchar(70);

        DECLARE p_numero_nrc varchar(70);

        DECLARE p_fecha_resolucion datetime;

        DECLARE p_numero_resolucion varchar(80);

        DECLARE p_serie varchar(175);

        DECLARE p_moneda varchar(35);

        DECLARE p_idcurrency int;

		DECLARE p_simbolo varchar(3);



		DECLARE p_idcredito int;

        DECLARE p_codigo_credito varchar(175);

        DECLARE p_monto_credito DECIMAL(13,2);

        DECLARE p_monto_abonado DECIMAL(13,2);

        DECLARE p_monto_restante DECIMAL(13,2);

        DECLARE p_fecha_abono datetime;

        DECLARE p_monto_abono DECIMAL(13,2);

        DECLARE p_total_abonado DECIMAL(13,2);

        DECLARE p_restante_credito DECIMAL(13,2);

        DECLARE p_cliente varchar(150);

        DECLARE p_usuario varchar(70);



        SET p_idmax = (SELECT MAX(idabono) FROM abono);

        SET p_idparametro = (SELECT MAX(idparametro) FROM parametro);

        SET p_idcurrency = (SELECT idcurrency FROM parametro WHERE idparametro = p_idparametro);

        SET p_empresa = (SELECT nombre_empresa FROM parametro);

        SET p_propietario = (SELECT propietario FROM parametro);

        SET p_direccion = (SELECT direccion_empresa FROM parametro);

        SET p_numero_nit = (SELECT numero_nit FROM parametro);

        SET p_numero_nrc = (SELECT numero_nrc FROM parametro);

        SET p_fecha_resolucion = (SELECT fecha_resolucion FROM tiraje_comprobante WHERE idcomprobante = 1);

        SET p_numero_resolucion = (SELECT numero_resolucion FROM tiraje_comprobante WHERE idcomprobante = 1);

        SET p_serie = (SELECT serie FROM tiraje_comprobante WHERE idcomprobante = 1);

        SET p_moneda = (SELECT CurrencyName	FROM currency WHERE idcurrency = p_idcurrency);

		SET p_simbolo = (SELECT Symbol FROM currency WHERE idcurrency = p_idcurrency);









		IF (p_idabono = '') THEN



        SET p_idcredito = (SELECT idcredito FROM abono WHERE idabono = p_idmax);

        SET p_fecha_abono = (SELECT fecha_abono FROM abono where idabono = p_idmax);

        SET p_monto_abono = (SELECT monto_abono FROM abono where idabono = p_idmax);

        SET p_total_abonado = (SELECT total_abonado FROM abono where idabono = p_idmax);

        SET p_restante_credito = (SELECT restante_credito FROM abono where idabono = p_idmax);

        SET p_usuario = (SELECT usuario FROM view_abonos where idabono = p_idmax);

		SET p_codigo_credito = (SELECT codigo_credito FROM credito WHERE idcredito = p_idcredito);

        SET p_monto_credito = (SELECT monto_credito  FROM credito WHERE idcredito = p_idcredito);

        SET p_monto_abonado = (SELECT monto_abonado FROM credito WHERE idcredito = p_idcredito);

        SET p_monto_restante = (SELECT monto_restante FROM credito WHERE idcredito = p_idcredito);

        SET p_cliente = (SELECT cliente FROM view_creditos_venta WHERE idcredito = p_idcredito);





        SELECT p_empresa, p_propietario, p_direccion, p_numero_nit , p_numero_nrc,

        DATE_FORMAT(p_fecha_resolucion,'%d/%m/%Y %k:%i %p')  as p_fecha_resolucion,p_numero_resolucion,

        p_serie,p_fecha_abono,p_monto_abono,p_codigo_credito,p_monto_credito,p_monto_abonado,p_monto_restante,

        p_total_abonado,p_restante_credito,p_moneda,p_simbolo,p_cliente,p_usuario;



        ELSE



        SET p_idcredito = (SELECT idcredito FROM abono WHERE idabono = p_idabono);

        SET p_fecha_abono = (SELECT fecha_abono FROM abono where idabono = p_idabono);

        SET p_monto_abono = (SELECT monto_abono FROM abono where idabono = p_idabono);

		SET p_total_abonado = (SELECT total_abonado FROM abono where idabono = p_idabono);

        SET p_usuario = (SELECT usuario FROM view_abonos where idabono = p_idabono);

        SET p_restante_credito = (SELECT restante_credito FROM abono where idabono = p_idabono);

		SET p_codigo_credito = (SELECT codigo_credito FROM credito WHERE idcredito = p_idcredito);

        SET p_monto_credito = (SELECT monto_credito  FROM credito WHERE idcredito = p_idcredito);

        SET p_monto_abonado = (SELECT monto_abonado FROM credito WHERE idcredito = p_idcredito);

        SET p_monto_restante = (SELECT monto_restante FROM credito WHERE idcredito = p_idcredito);

        SET p_cliente = (SELECT cliente FROM view_creditos_venta WHERE idcredito = p_idcredito);



        SELECT p_empresa, p_propietario, p_direccion, p_numero_nit , p_numero_nrc,

        DATE_FORMAT(p_fecha_resolucion,'%d/%m/%Y %k:%i %p')  as p_fecha_resolucion,p_numero_resolucion,

        p_serie,p_fecha_abono,p_monto_abono,p_codigo_credito,p_monto_credito,p_monto_abonado,p_monto_restante,

        p_total_abonado,p_restante_credito,p_moneda,p_simbolo,p_cliente,p_usuario;



		END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_imprimir_ticket_apartado` (IN `p_idapartado` INT(11))   BEGIN





        DECLARE p_idmax int;

        DECLARE p_idparametro int;

        DECLARE p_empresa varchar(150);

        DECLARE p_propietario varchar(150);

        DECLARE p_direccion varchar(200);

        DECLARE p_numero_nit varchar(70);

        DECLARE p_numero_nrc varchar(70);

        DECLARE p_fecha_resolucion datetime;

        DECLARE p_numero_resolucion varchar(80);

        DECLARE p_serie varchar(175);

        DECLARE p_subtotal DECIMAL(13,2);

        DECLARE p_exento DECIMAL(13,2);

        DECLARE p_descuento DECIMAL(13,2);

        DECLARE p_total DECIMAL(13,2);

        DECLARE p_numero_productos DECIMAL(13,2);

        DECLARE p_empleado varchar(181);

        DECLARE p_numero_apartado varchar(175);

        DECLARE p_fecha_apartado datetime;

        DECLARE p_moneda varchar(35);

        DECLARE p_idcurrency int;

        DECLARE p_estado tinyint(1);



		DECLARE p_abonado_apartado DECIMAL(13,2);

        DECLARE p_restante_pagar DECIMAL(13,2);

		DECLARE p_fecha_limite_retiro datetime;

        DECLARE p_diferencia_fechas int;



        SET p_idmax = (SELECT MAX(idapartado) FROM apartado);

        SET p_idparametro = (SELECT MAX(idparametro) FROM parametro);

        SET p_idcurrency = (SELECT idcurrency FROM parametro WHERE idparametro = p_idparametro);

        SET p_empresa = (SELECT nombre_empresa FROM parametro);

        SET p_propietario = (SELECT propietario FROM parametro);

        SET p_direccion = (SELECT direccion_empresa FROM parametro);

        SET p_numero_nit = (SELECT numero_nit FROM parametro);

        SET p_numero_nrc = (SELECT numero_nrc FROM parametro);

        SET p_fecha_resolucion = (SELECT fecha_resolucion FROM tiraje_comprobante WHERE idcomprobante = 1);

        SET p_numero_resolucion = (SELECT numero_resolucion FROM tiraje_comprobante WHERE idcomprobante = 1);

        SET p_serie = (SELECT serie FROM tiraje_comprobante WHERE idcomprobante = 1);

        SET p_moneda = (SELECT CurrencyName	FROM currency WHERE idcurrency = p_idcurrency);







		IF (p_idapartado= '') THEN



		SET p_subtotal = (SELECT (sumas + iva) as subtotal FROM apartado WHERE idapartado= p_idmax);

		SET p_exento = (SELECT exento FROM apartado WHERE idapartado= p_idmax);

		SET p_descuento = (SELECT descuento FROM apartado WHERE idapartado= p_idmax);

		SET p_total = (SELECT total FROM apartado WHERE idapartado= p_idmax);

		SET p_numero_productos = (SELECT SUM(cantidad) FROM detalleapartado WHERE idapartado= p_idmax);

		SET p_empleado = (SELECT empleado FROM view_apartados WHERE idapartado= p_idmax GROUP BY empleado);

		SET p_numero_apartado = (SELECT numero_apartado FROM apartado WHERE idapartado= p_idmax);

		SET p_fecha_apartado = (SELECT fecha_apartado FROM apartado WHERE idapartado= p_idmax);

		SET p_abonado_apartado  = (SELECT abonado_apartado FROM apartado WHERE idapartado= p_idmax);

		SET p_restante_pagar  = (SELECT restante_pagar FROM apartado WHERE idapartado= p_idmax);

		SET p_fecha_limite_retiro = (SELECT fecha_limite_retiro	 FROM apartado WHERE idapartado= p_idmax);

		SET p_estado = (SELECT estado FROM apartado WHERE idapartado= p_idmax);

        SET p_diferencia_fechas = (SELECT DATEDIFF(p_fecha_limite_retiro, p_fecha_apartado));





        SELECT p_empresa, p_propietario, p_direccion, p_numero_nit , p_numero_nrc,

        DATE_FORMAT(p_fecha_resolucion,'%d/%m/%Y %k:%i %p')  as p_fecha_resolucion,p_numero_resolucion,

        p_serie, p_subtotal, p_exento, p_descuento, p_total, p_numero_productos,

		p_empleado,DATE_FORMAT(p_fecha_apartado,'%d/%m/%Y %k:%i %p') as p_fecha_apartado ,p_numero_apartado,

      	p_fecha_limite_retiro, p_restante_pagar ,p_abonado_apartado,p_moneda,p_estado,p_diferencia_fechas;



        ELSE



		SET p_subtotal = (SELECT (sumas + iva) as subtotal FROM apartado WHERE idapartado= p_idapartado);

		SET p_exento = (SELECT exento FROM apartado WHERE idapartado= p_idapartado);

		SET p_descuento = (SELECT descuento FROM apartado WHERE idapartado= p_idapartado);

        SET p_total = (SELECT total FROM apartado WHERE idapartado= p_idapartado);

        SET p_numero_productos = (SELECT SUM(cantidad) FROM detalleapartado WHERE idapartado= p_idapartado);

        SET p_empleado = (SELECT empleado FROM view_apartados WHERE idapartado=  p_idapartado GROUP BY empleado);

		SET p_numero_apartado = (SELECT numero_apartado FROM apartado WHERE idapartado= p_idapartado);

		SET p_fecha_apartado = (SELECT fecha_apartado FROM apartado WHERE idapartado=  p_idapartado);

		SET p_abonado_apartado  = (SELECT abonado_apartado FROM apartado WHERE idapartado= p_idapartado);

		SET p_restante_pagar  = (SELECT restante_pagar FROM apartado WHERE idapartado= p_idapartado);

		SET p_fecha_limite_retiro = (SELECT fecha_limite_retiro	 FROM apartado WHERE idapartado= p_idapartado);

        SET p_estado = (SELECT estado FROM apartado WHERE idapartado= p_idapartado);

		SET p_diferencia_fechas = (SELECT DATEDIFF(p_fecha_limite_retiro, p_fecha_apartado));



		SELECT p_empresa, p_propietario, p_direccion, p_numero_nit , p_numero_nrc,

        DATE_FORMAT(p_fecha_resolucion,'%d/%m/%Y %k:%i %p')  as p_fecha_resolucion,p_numero_resolucion,

        p_serie,  p_subtotal, p_exento, p_descuento, p_total, p_numero_productos,

		p_empleado,DATE_FORMAT(p_fecha_apartado,'%d/%m/%Y %k:%i %p') as p_fecha_apartado ,p_numero_apartado,

      	p_fecha_limite_retiro, p_restante_pagar ,p_abonado_apartado,p_moneda,p_estado,p_diferencia_fechas;



		END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_abono` (IN `p_idcredito` INT(11), IN `p_monto_abono` DECIMAL(13,2), IN `p_idusuario` INT(11))   BEGIN

DECLARE p_codigo_credito varchar(175);

DECLARE p_monto_restante DECIMAL(13,2);

DECLARE p_resta_montos DECIMAL(13,2);

DECLARE p_monto_abonado DECIMAL(13,2);

DECLARE p_idventa int;



SET p_monto_restante = (SELECT monto_restante FROM credito WHERE idcredito = p_idcredito);

SET p_resta_montos = (p_monto_restante - p_monto_abono);

SET p_idventa = (SELECT idventa FROM credito WHERE idcredito = p_idcredito);

SET p_codigo_credito = (SELECT codigo_credito FROM credito WHERE idcredito = p_idcredito);



IF p_resta_montos = 0 THEN



	UPDATE credito SET

	monto_restante = 0.00,

    monto_abonado = monto_abonado + p_monto_abono,

    estado = 1

	WHERE idcredito = p_idcredito;



    SET p_monto_abonado = (SELECT monto_abonado FROM credito WHERE idcredito = p_idcredito);



    CALL sp_insert_caja_movimiento(1,p_monto_abono,(CONCAT('POR ABONO A CREDITO',' ',p_codigo_credito)));



    INSERT INTO `abono`(`idcredito`, `fecha_abono`, `monto_abono`, `total_abonado`,`restante_credito`,`idusuario`)

	VALUES (p_idcredito, NOW(), p_monto_abono,p_monto_abonado, 0.00,p_idusuario);



ELSEIF p_resta_montos > 0 THEN

	UPDATE credito SET

	monto_restante = p_resta_montos,

    monto_abonado = monto_abonado + p_monto_abono

	WHERE idcredito = p_idcredito;



	SET p_monto_abonado = (SELECT monto_abonado FROM credito WHERE idcredito = p_idcredito);



	    CALL sp_insert_caja_movimiento(1,p_monto_abono,(CONCAT('POR ABONO A CREDITO',' ',p_codigo_credito)));



    INSERT INTO `abono`(`idcredito`, `fecha_abono`, `monto_abono`, `total_abonado`,`restante_credito`,`idusuario`)

	VALUES (p_idcredito, NOW(), p_monto_abono,p_monto_abonado, p_resta_montos,p_idusuario);



END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_apartado` (IN `p_fecha_limite_retiro` DATETIME, IN `p_sumas` DECIMAL(13,2), IN `p_iva` DECIMAL(13,2), IN `p_exento` DECIMAL(13,2), IN `p_retenido` DECIMAL(13,2), IN `p_descuento` DECIMAL(13,2), IN `p_total` DECIMAL(13,2), IN `p_abonado_apartado` DECIMAL(13,2), IN `p_restante_pagar` DECIMAL(13,2), IN `p_sonletras` VARCHAR(150), IN `p_idcliente` INT(11), IN `p_idusuario` INT(11))   BEGIN

	INSERT INTO `apartado`(`fecha_apartado`,

	`fecha_limite_retiro`, `sumas`, `iva`, `exento`, `retenido`, `descuento`,

	`total`, `abonado_apartado`, `restante_pagar`, `sonletras`,`idcliente`, `idusuario`)

	VALUES (NOW(), p_fecha_limite_retiro,

	p_sumas, p_iva, p_exento, p_retenido, p_descuento, p_total, p_abonado_apartado,

	p_restante_pagar, p_sonletras, p_idcliente, p_idusuario);



    CALL sp_insert_caja_apartado(p_abonado_apartado);



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_caja_apartado` (IN `p_monto_movimiento` DECIMAL(13,2))   BEGIN



	

    DECLARE p_idcaja int(11);

    DECLARE p_descripcion_movimiento varchar(80);

    DECLARE p_numero_apartado varchar(175);



    SET p_numero_apartado = (SELECT max(numero_apartado) FROM apartado);

    SET p_idcaja = (SELECT idcaja FROM `caja` WHERE DATE(fecha_apertura) = CURDATE());

	SET p_descripcion_movimiento = (CONCAT('POR APARTADO #',' ',p_numero_apartado));



	INSERT INTO `caja_movimiento`(`idcaja`, `tipo_movimiento`, `monto_movimiento`,

    `descripcion_movimiento`,`fecha_movimiento`) VALUES (p_idcaja, 1, p_monto_movimiento,

	 p_descripcion_movimiento,curdate());



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_caja_movimiento` (IN `p_tipo_movimiento` TINYINT(1), IN `p_monto_movimiento` DECIMAL(13,2), IN `p_descripcion_movimiento` VARCHAR(80))   BEGIN

    DECLARE p_idcaja int(11);

    DECLARE p_tipo_comprobante tinyint(1);

    DECLARE p_numero_comprobante int(11);



    SET p_idcaja = (SELECT idcaja FROM `caja` WHERE DATE(fecha_apertura) = CURDATE());





	INSERT INTO `caja_movimiento`(`idcaja`, `tipo_movimiento`, `monto_movimiento`,

    `descripcion_movimiento`,`fecha_movimiento`) VALUES (p_idcaja, p_tipo_movimiento, p_monto_movimiento,

     p_descripcion_movimiento,curdate());





END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_caja_venta` (IN `p_monto_movimiento` DECIMAL(13,2))   BEGIN
/*
este sp se llamaba en el sp de insertar ventas, pero comenté esa parte
*/
	DECLARE p_idventa int(11);

    DECLARE p_idcaja int(11);

    DECLARE p_tipo_comprobante tinyint(1);

    DECLARE p_numero_comprobante int(11);

    DECLARE p_descripcion_movimiento varchar(80);



    SET p_idventa = (SELECT max(idventa) FROM venta);

    SET p_idcaja = (SELECT idcaja FROM `caja` WHERE DATE(fecha_apertura) = CURDATE());

    SET p_tipo_comprobante = (SELECT tipo_comprobante FROM `venta` WHERE idventa = p_idventa);

    SET p_numero_comprobante = (SELECT numero_comprobante FROM `venta` WHERE idventa = p_idventa);



    IF p_tipo_comprobante = 1 THEN

	SET p_descripcion_movimiento = (CONCAT('POR VENTA',' ','TICKET', ' # ',p_numero_comprobante));

	INSERT INTO `caja_movimiento`(`idcaja`, `tipo_movimiento`, `monto_movimiento`,

    `descripcion_movimiento`,`fecha_movimiento`) VALUES (p_idcaja, 1, p_monto_movimiento,

	p_descripcion_movimiento,curdate());

	ELSEIF p_tipo_comprobante = 2 THEN

     SET p_descripcion_movimiento = (CONCAT('POR VENTA',' ','FACTURA', ' # ',p_numero_comprobante));

	INSERT INTO `caja_movimiento`(`idcaja`, `tipo_movimiento`, `monto_movimiento`,

    `descripcion_movimiento`,`fecha_movimiento`) VALUES (p_idcaja, 1, p_monto_movimiento,

	p_descripcion_movimiento,curdate());

	ELSEIF p_tipo_comprobante = 3 THEN

     SET p_descripcion_movimiento = (CONCAT('POR VENTA',' ','BOLETA', ' # ',p_numero_comprobante));

	INSERT INTO `caja_movimiento`(`idcaja`, `tipo_movimiento`, `monto_movimiento`,

    `descripcion_movimiento`,`fecha_movimiento`) VALUES (p_idcaja,1, p_monto_movimiento,

	p_descripcion_movimiento,curdate());

    END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_categoria` (IN `p_nombre_categoria` VARCHAR(120))   BEGIN

    IF NOT EXISTS (SELECT * FROM `categoria` WHERE `nombre_categoria` = p_nombre_categoria) THEN

		INSERT INTO `categoria`(`nombre_categoria`)

		VALUES (p_nombre_categoria);

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_cliente` (IN `p_nombre_cliente` VARCHAR(150), IN `p_numero_nit` VARCHAR(70), IN `p_numero_nrc` VARCHAR(45), IN `p_direccion_cliente` VARCHAR(100), IN `p_numero_telefono` VARCHAR(70), IN `p_email` VARCHAR(80), IN `p_giro` VARCHAR(80), IN `p_limite_credito` DECIMAL(13,2), IN `p_dias_pagar` INT(5))   BEGIN

	IF NOT EXISTS (SELECT * FROM `cliente` WHERE `nombre_cliente` = p_nombre_cliente) THEN

			INSERT INTO `cliente`(`nombre_cliente`, `numero_nit`,

			`numero_nrc`, `direccion_cliente`, `numero_telefono`, `email`, `giro`,

			`limite_credito`,`iddias`)

			VALUES (p_nombre_cliente, p_numero_nit,

			p_numero_nrc, p_direccion_cliente, p_numero_telefono, p_email, p_giro,

			p_limite_credito,p_dias_pagar);

	END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_compra` (IN `p_fecha_compra` DATETIME, IN `p_idproveedor` INT(11), IN `p_tipo_pago` VARCHAR(75), IN `p_numero_comprobante` VARCHAR(60), IN `p_tipo_comprobante` VARCHAR(60), IN `p_fecha_comprobante` DATE, IN `p_sumas` DECIMAL(13,2), IN `p_iva` DECIMAL(13,2), IN `p_exento` DECIMAL(13,2), IN `p_retenido` DECIMAL(13,2), IN `p_total` DECIMAL(13,2), IN `p_sonletras` VARCHAR(150))   BEGIN

   IF NOT EXISTS (SELECT * FROM `compra` WHERE `fecha_comprobante` = p_fecha_comprobante

   AND `numero_comprobante` = p_numero_comprobante) THEN

		INSERT INTO `compra`(`fecha_compra`, `idproveedor`, `tipo_pago`,

		`numero_comprobante`, `tipo_comprobante`, `fecha_comprobante`, `sumas`,

		`iva`, `exento`, `retenido`, `total`,`sonletras`)

		VALUES (p_fecha_compra, p_idproveedor, p_tipo_pago,

		p_numero_comprobante, p_tipo_comprobante, p_fecha_comprobante, p_sumas,

		p_iva, p_exento, p_retenido, p_total, p_sonletras);

   END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_comprobante` (IN `p_nombre_comprobante` VARCHAR(75))   BEGIN

   IF NOT EXISTS (SELECT * FROM `comprobante` WHERE `nombre_comprobante` = p_nombre_comprobante) THEN

	INSERT INTO `comprobante`(`nombre_comprobante`)

	VALUES (p_nombre_comprobante);

   END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_cotizacion` (IN `p_a_nombre` VARCHAR(175), IN `p_tipo_pago` VARCHAR(60), IN `p_entrega` VARCHAR(60), IN `p_sumas` DECIMAL(13,2), IN `p_iva` DECIMAL(13,2), IN `p_exento` DECIMAL(13,2), IN `p_retenido` DECIMAL(13,2), IN `p_descuento` DECIMAL(13,2), IN `p_total` DECIMAL(13,2), IN `p_sonletras` VARCHAR(150), IN `p_idusuario` INT(11), IN `p_idcliente` INT(11))   BEGIN

INSERT INTO `cotizacion`(`fecha_cotizacion`, `a_nombre`,

`tipo_pago`, `entrega`, `sumas`, `iva`,

`exento`, `retenido`, `descuento`, `total`,

`sonletras`,`idusuario`,`idcliente`)

VALUES (NOW(), p_a_nombre,

p_tipo_pago, p_entrega, p_sumas, p_iva,

p_exento, p_retenido, p_descuento, p_total,

p_sonletras, p_idusuario,p_idcliente);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_credito_venta` (IN `p_monto_credito` DECIMAL(13,2), IN `p_idcliente` INT(11))   BEGIN



    DECLARE p_idventa int(11);

    DECLARE p_numero_venta varchar(175);

	DECLARE p_nombre_credito varchar(120);

	DECLARE p_idcredito INT;



    SET p_idventa = (SELECT MAX(idventa) FROM venta);

    SET p_numero_venta = (SELECT numero_venta FROM venta WHERE idventa = p_idventa);

    SET p_nombre_credito = (CONCAT('POR VENTA #',' ',p_numero_venta));

    SET p_idcredito = (SELECT MAX(idcredito) FROM credito);



	INSERT INTO `credito`(`idventa`, `nombre_credito`, `fecha_credito`,

	`monto_credito`,`monto_abonado`,`monto_restante`,`idcliente`)

	VALUES (p_idventa, p_nombre_credito, NOW(),p_monto_credito,

    0.00,p_monto_credito,p_idcliente);



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_currency` (IN `p_CurrencyISO` VARCHAR(3), IN `p_Language` VARCHAR(3), IN `p_CurrencyName` VARCHAR(35), IN `p_Money` VARCHAR(30), IN `p_Symbol` VARCHAR(3))   BEGIN

IF NOT EXISTS (SELECT * FROM `currency` WHERE `CurrencyName` = p_CurrencyName) THEN

		INSERT INTO `currency`(`CurrencyISO`, `Language`, `CurrencyName`, 

		`Money`, `Symbol`) 

		VALUES (p_CurrencyISO, p_Language, p_CurrencyName, 

		p_Money, p_Symbol);

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_detalleapartado` (IN `p_idproducto` INT(11), IN `p_cantidad` DECIMAL(13,2), IN `p_precio_unitario` DECIMAL(13,2), IN `p_exento` DECIMAL(13,2), IN `p_descuento` DECIMAL(13,2), IN `p_fecha_vence` DATE, IN `p_importe` DECIMAL(13,2))   BEGIN



	DECLARE p_idapartado int(11);

    DECLARE p_numero_apartado VARCHAR(175);

    DECLARE p_precio_compra DECIMAL(13,2);

    DECLARE p_costo DECIMAL(13,2);

    DECLARE p_total DECIMAL(13,2);

    DECLARE p_descr_salida varchar(150);

    DECLARE p_inventariable int(11);

    DECLARE	p_estado tinyint(1);

    DECLARE p_stock DECIMAL(13,2);

    DECLARE p_cantidad_perecedero DECIMAL(13,2);





    SET p_idapartado = (SELECT MAX(idapartado) FROM apartado);

    SET p_total = (SELECT total FROM apartado WHERE idapartado = p_idapartado);

    SET p_precio_compra = (SELECT precio_compra FROM producto WHERE idproducto = p_idproducto);

    SET p_numero_apartado = (SELECT numero_apartado FROM apartado WHERE idapartado = p_idapartado);

    SET p_costo = (p_cantidad * p_precio_compra);





    SET p_descr_salida = (CONCAT('POR APARTADO',' # ',p_numero_apartado));

    SET p_inventariable = (SELECT inventariable FROM producto WHERE idproducto = p_idproducto);

    SET p_estado = (SELECT estado FROM apartado WHERE idapartado = p_idapartado);

    SET p_cantidad_perecedero = (SELECT cantidad_perecedero FROM perecedero WHERE idproducto = p_idproducto

    AND fecha_vencimiento = p_fecha_vence AND estado = 1);

    SET p_stock = (SELECT stock FROM producto WHERE idproducto = p_idproducto);



		IF (p_inventariable  = 0) THEN



			IF p_idapartado IS NULL OR p_idapartado= '' THEN



				INSERT INTO `detalleapartado`(`idapartado`, `idproducto`, `cantidad`, `precio_unitario`,

				`fecha_vence`, `exento`, `descuento`, `importe`)

				VALUES (1, p_idproducto, p_cantidad, p_precio_unitario,

				p_fecha_vence, p_exento, p_descuento, p_importe);





				ELSE



				INSERT INTO `detalleapartado`(`idapartado`, `idproducto`, `cantidad`, `precio_unitario`,

				`fecha_vence`, `exento`, `descuento`, `importe`)

				VALUES (p_idapartado, p_idproducto, p_cantidad, p_precio_unitario,

				p_fecha_vence, p_exento, p_descuento, p_importe);



			END IF; 



		ELSE 

			IF (p_fecha_vence != '2000-01-01') THEN



				IF p_idapartado IS NULL OR p_idapartado= '' THEN



                    IF (p_stock > 0) THEN



							INSERT INTO `detalleapartado`(`idapartado`, `idproducto`, `cantidad`, `precio_unitario`,

							`fecha_vence`, `exento`, `descuento`, `importe`)

							VALUES (1, p_idproducto, p_cantidad, p_precio_unitario,

							p_fecha_vence, p_exento, p_descuento, p_importe);



							INSERT INTO `salida`(`mes_inventario`,`fecha_salida`, `descripcion_salida`, `cantidad_salida`,

							`precio_unitario_salida`, `costo_total_salida`,`idproducto`,`idapartado`)

							VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),NOW(),p_descr_salida,p_cantidad,p_precio_compra,p_costo,p_idproducto,1);



							UPDATE `inventario` SET

							`saldo_final` = `saldo_final` - p_cantidad,

							`salidas` = `salidas` + p_cantidad

							WHERE idproducto = p_idproducto AND fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

							AND fecha_cierre = LAST_DAY(CURDATE());



							CALL sp_descontar_perecedero(p_idproducto, p_cantidad, p_fecha_vence);



							UPDATE `producto` SET

							`stock` = `stock` - p_cantidad

							WHERE idproducto = p_idproducto;



                    END IF; 

			ELSE 

					 IF (p_stock > 0) THEN



							INSERT INTO `detalleapartado`(`idapartado`, `idproducto`, `cantidad`, `precio_unitario`,

							`fecha_vence`, `exento`, `descuento`, `importe`)

							VALUES (p_idapartado, p_idproducto, p_cantidad, p_precio_unitario,

							p_fecha_vence, p_exento, p_descuento, p_importe);



							INSERT INTO `salida`(`mes_inventario`,`fecha_salida`, `descripcion_salida`, `cantidad_salida`,

							`precio_unitario_salida`, `costo_total_salida`,`idproducto`,`idapartado`)

							VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),NOW(),p_descr_salida,p_cantidad,p_precio_compra,p_costo,p_idproducto,p_idapartado);



							UPDATE `inventario` SET

							`saldo_final` = `saldo_final` - p_cantidad,

							`salidas` = `salidas` + p_cantidad

							WHERE idproducto = p_idproducto AND fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

							AND fecha_cierre = LAST_DAY(CURDATE());



							CALL sp_descontar_perecedero(p_idproducto, p_cantidad, p_fecha_vence);



							UPDATE `producto` SET

							`stock` = `stock` - p_cantidad

							WHERE idproducto = p_idproducto;



						END IF; 

					END IF; 

				ELSE  

                IF p_idapartado IS NULL OR p_idapartado= '' THEN



                    IF (p_stock > 0) THEN



                            INSERT INTO `detalleapartado`(`idapartado`, `idproducto`, `cantidad`, `precio_unitario`,

							`fecha_vence`, `exento`, `descuento`, `importe`)

							VALUES (1, p_idproducto, p_cantidad, p_precio_unitario,

							NULL, p_exento, p_descuento, p_importe);



							INSERT INTO `salida`(`mes_inventario`,`fecha_salida`, `descripcion_salida`, `cantidad_salida`,

							`precio_unitario_salida`, `costo_total_salida`,`idproducto`,`idapartado`)

							VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),NOW(),p_descr_salida,p_cantidad,p_precio_compra,p_costo,p_idproducto,1);



							UPDATE `inventario` SET

							`saldo_final` = `saldo_final` - p_cantidad,

							`salidas` = `salidas` + p_cantidad

							WHERE idproducto = p_idproducto AND fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

							AND fecha_cierre = LAST_DAY(CURDATE());





							UPDATE `producto` SET

							`stock` = `stock` - p_cantidad

							WHERE idproducto = p_idproducto;



                    END IF; 

			ELSE 

					 IF (p_stock > 0) THEN



							INSERT INTO `detalleapartado`(`idapartado`, `idproducto`, `cantidad`, `precio_unitario`,

							`fecha_vence`, `exento`, `descuento`, `importe`)

							VALUES (p_idapartado, p_idproducto, p_cantidad, p_precio_unitario,

							NULL, p_exento, p_descuento, p_importe);



							INSERT INTO `salida`(`mes_inventario`,`fecha_salida`, `descripcion_salida`, `cantidad_salida`,

							`precio_unitario_salida`, `costo_total_salida`,`idproducto`,`idapartado`)

							VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),NOW(),p_descr_salida,p_cantidad,p_precio_compra,p_costo,p_idproducto,p_idapartado);



							UPDATE `inventario` SET

							`saldo_final` = `saldo_final` - p_cantidad,

							`salidas` = `salidas` + p_cantidad

							WHERE idproducto = p_idproducto AND fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

							AND fecha_cierre = LAST_DAY(CURDATE());





							UPDATE `producto` SET

							`stock` = `stock` - p_cantidad

							WHERE idproducto = p_idproducto;



						END IF; 

					END IF; 

			END IF; 

		END IF;  

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_detallecompra` (IN `p_idproducto` INT(11), IN `p_cantidad` DECIMAL(13,2), IN `p_precio_unitario` DECIMAL(13,2), IN `p_exento` DECIMAL(13,2), IN `p_fecha_vencimiento` DATE, IN `p_importe` DECIMAL(13,2))   BEGIN



	DECLARE p_idcompra int(11);

	DECLARE p_idproveedor int(11);

    DECLARE p_costo DECIMAL(13,2);

    DECLARE p_numero_comprobante varchar(60);

    DECLARE p_tipo_comprobante varchar(60);

    DECLARE p_descr_entrada varchar(150);

    DECLARE p_inventariable int(11);





    SET p_idcompra = (SELECT MAX(idcompra) FROM compra);

    SET p_idproveedor = (SELECT idproveedor FROM compra WHERE idcompra = p_idcompra);

    SET p_costo = (p_cantidad * p_precio_unitario);

    SET p_numero_comprobante = (SELECT numero_comprobante FROM compra WHERE idcompra = p_idcompra);

    SET p_tipo_comprobante = (SELECT tipo_comprobante FROM compra WHERE idcompra = p_idcompra);





    IF(p_tipo_comprobante = 1)THEN

		SET p_descr_entrada = (CONCAT('POR COMPRA',' TICKET # ',p_numero_comprobante));

	ELSEIF (p_tipo_comprobante = 2) THEN

		SET p_descr_entrada = (CONCAT('POR COMPRA',' FACTURA # ',p_numero_comprobante));

	ELSEIF (p_tipo_comprobante = 3) THEN

		SET p_descr_entrada = (CONCAT('POR COMPRA',' BOLETA # ',p_numero_comprobante));

    END IF;



    SET p_inventariable = (SELECT inventariable FROM producto WHERE idproducto = p_idproducto);





    IF (p_inventariable  = 0) THEN



	  IF p_idcompra IS NULL OR p_idcompra = '' THEN




		INSERT INTO `detallecompra`(`idcompra`, `idproducto`, `fecha_vence`, `cantidad`, `precio_unitario`,

		`exento`, `importe`)

		VALUES (1, p_idproducto, NULL ,p_cantidad, p_precio_unitario,

		p_exento, p_importe);



		INSERT INTO `proveedor_precio`(`idproveedor`, `idproducto`, `fecha_precio`, `precio_compra`)

		VALUES (p_idproveedor, p_idproducto, CURDATE(), p_precio_unitario);



		ELSE



		INSERT INTO `detallecompra`(`idcompra`, `idproducto`, `fecha_vence`, `cantidad`, `precio_unitario`,

		`exento`, `importe`)

		VALUES (p_idcompra, p_idproducto, NULL, p_cantidad, p_precio_unitario,

		p_exento, p_importe);





		INSERT INTO `proveedor_precio`(`idproveedor`, `idproducto`, `fecha_precio`, `precio_compra`)

		VALUES (p_idproveedor, p_idproducto, CURDATE(), p_precio_unitario);



		END IF;



    ELSE



    IF (p_fecha_vencimiento != '2000-01-01') THEN



        IF p_idcompra IS NULL OR p_idcompra = '' THEN



			INSERT INTO `detallecompra`(`idcompra`, `idproducto`, `fecha_vence`, `cantidad`, `precio_unitario`,

			`exento`, `importe`)

			VALUES (1, p_idproducto, p_fecha_vencimiento,  p_cantidad, p_precio_unitario,

			p_exento, p_importe);



			INSERT INTO `entrada`(`mes_inventario`,`fecha_entrada`, `descripcion_entrada`, `cantidad_entrada`,

			`precio_unitario_entrada`, `costo_total_entrada`,`idproducto`,`idcompra`)

			VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),NOW(),p_descr_entrada,p_cantidad,p_precio_unitario,p_costo,p_idproducto,1);



			INSERT INTO `proveedor_precio`(`idproveedor`, `idproducto`, `fecha_precio`, `precio_compra`)

			VALUES (p_idproveedor, p_idproducto, CURDATE(), p_precio_unitario);



			UPDATE `inventario` SET

			`saldo_final` = `saldo_final` + p_cantidad,

            `entradas` = `entradas` + p_cantidad

			WHERE idproducto = p_idproducto AND fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

			AND fecha_cierre = LAST_DAY(CURDATE());



			IF NOT EXISTS (SELECT * FROM perecedero WHERE fecha_vencimiento = p_fecha_vencimiento

			AND idproducto = p_idproducto) THEN

				INSERT INTO `perecedero` (`fecha_vencimiento`, `cantidad_perecedero`, `idproducto`)

				VALUES (p_fecha_vencimiento,p_cantidad,p_idproducto);

			   ELSE

			   UPDATE `perecedero` SET

			   `cantidad_perecedero` = `cantidad_perecedero` + p_cantidad

			   WHERE `idproducto` = p_idproducto AND `fecha_vencimiento` = p_fecha_vencimiento;

			END IF;



			UPDATE `producto` SET

			`stock` = `stock` + p_cantidad

			WHERE idproducto = p_idproducto;



		ELSE



			INSERT INTO `detallecompra`(`idcompra`, `idproducto`, `fecha_vence`, `cantidad`, `precio_unitario`,

			`exento`, `importe`)

			VALUES (p_idcompra, p_idproducto, p_fecha_vencimiento, p_cantidad, p_precio_unitario,

			p_exento, p_importe);



			INSERT INTO `entrada`(`mes_inventario`,`fecha_entrada`, `descripcion_entrada`, `cantidad_entrada`,

			`precio_unitario_entrada`, `costo_total_entrada`,`idproducto`,`idcompra`)

			VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),NOW(),p_descr_entrada,p_cantidad,p_precio_unitario,p_costo,p_idproducto,p_idcompra);



			INSERT INTO `proveedor_precio`(`idproveedor`, `idproducto`, `fecha_precio`, `precio_compra`)

			VALUES (p_idproveedor, p_idproducto, CURDATE(), p_precio_unitario);



			UPDATE `inventario` SET

			`saldo_final` = `saldo_final` + p_cantidad,

            `entradas` = `entradas` + p_cantidad

			WHERE idproducto = p_idproducto AND fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

			AND fecha_cierre = LAST_DAY(CURDATE());



			IF NOT EXISTS (SELECT * FROM perecedero WHERE fecha_vencimiento = p_fecha_vencimiento

			AND idproducto = p_idproducto) THEN

				INSERT INTO `perecedero` (`fecha_vencimiento`, `cantidad_perecedero`, `idproducto`)

				VALUES (p_fecha_vencimiento,p_cantidad,p_idproducto);

			   ELSE

			   UPDATE `perecedero` SET

			   `cantidad_perecedero` = `cantidad_perecedero` + p_cantidad

			   WHERE `idproducto` = p_idproducto AND `fecha_vencimiento` = p_fecha_vencimiento;

			END IF;





			UPDATE `producto` SET

			`stock` = `stock` + p_cantidad

			WHERE idproducto = p_idproducto;



			END IF;



	ELSE



		IF p_idcompra IS NULL OR p_idcompra = '' THEN



		INSERT INTO `detallecompra`(`idcompra`, `idproducto`, `fecha_vence`, `cantidad`, `precio_unitario`,

		`exento`, `importe`)

		VALUES (1, p_idproducto, NULL, p_cantidad, p_precio_unitario,

		p_exento, p_importe);



		INSERT INTO `entrada`(`mes_inventario`,`fecha_entrada`, `descripcion_entrada`, `cantidad_entrada`,

		`precio_unitario_entrada`, `costo_total_entrada`,`idproducto`,`idcompra`)

		VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),NOW(),p_descr_entrada,p_cantidad,p_precio_unitario,p_costo,p_idproducto,1);



		INSERT INTO `proveedor_precio`(`idproveedor`, `idproducto`, `fecha_precio`, `precio_compra`)

		VALUES (p_idproveedor, p_idproducto, CURDATE(), p_precio_unitario);



		UPDATE `inventario` SET

		`saldo_final` = `saldo_final` + p_cantidad,

		`entradas` = `entradas` + p_cantidad

		WHERE idproducto = p_idproducto AND fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

		AND fecha_cierre = LAST_DAY(CURDATE());



		UPDATE `producto` SET

		`stock` = `stock` + p_cantidad

		WHERE idproducto = p_idproducto;



		ELSE



		INSERT INTO `detallecompra`(`idcompra`, `idproducto`, `fecha_vence`, `cantidad`, `precio_unitario`,

		`exento`, `importe`)

		VALUES (p_idcompra, p_idproducto, NULL, p_cantidad, p_precio_unitario,

		p_exento, p_importe);



		INSERT INTO `entrada`(`mes_inventario`,`fecha_entrada`, `descripcion_entrada`, `cantidad_entrada`,

		`precio_unitario_entrada`, `costo_total_entrada`,`idproducto`,`idcompra`)

		VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),NOW(),p_descr_entrada,p_cantidad,p_precio_unitario,p_costo,p_idproducto,p_idcompra);





		INSERT INTO `proveedor_precio`(`idproveedor`, `idproducto`, `fecha_precio`, `precio_compra`)

		VALUES (p_idproveedor, p_idproducto, CURDATE(), p_precio_unitario);



		UPDATE `inventario` SET

		`saldo_final` = `saldo_final` + p_cantidad,

		`entradas` = `entradas` + p_cantidad

		WHERE idproducto = p_idproducto AND fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

		AND fecha_cierre = LAST_DAY(CURDATE());



		UPDATE `producto` SET

		`stock` = `stock` + p_cantidad

		WHERE idproducto = p_idproducto;



		END IF;



	 END IF;



    END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_detallecotizacion` (IN `p_idproducto` INT(11), IN `p_cantidad` DECIMAL(13,2), IN `p_disponible` TINYINT(1), IN `p_precio_unitario` DECIMAL(13,2), IN `p_exento` DECIMAL(13,2), IN `p_descuento` DECIMAL(13,2), IN `p_importe` DECIMAL(13,2))   BEGIN

	DECLARE p_idcotizacion int(11);

	SET p_idcotizacion  = (SELECT MAX(idcotizacion) FROM cotizacion);



    IF p_idcotizacion IS NULL OR p_idcotizacion = '' THEN

		INSERT INTO `detallecotizacion`(`idcotizacion`, `idproducto`, `cantidad`, `disponible`,

        `precio_unitario`, `exento`, `descuento`, `importe`)

		VALUES (1, p_idproducto, p_cantidad, p_disponible, p_precio_unitario,

		p_exento, p_descuento, p_importe);

	ELSE

		INSERT INTO `detallecotizacion`(`idcotizacion`, `idproducto`, `cantidad`, `disponible`,

        `precio_unitario`,

		`exento`, `descuento`, `importe`)

		VALUES (p_idcotizacion, p_idproducto, p_cantidad, p_disponible, p_precio_unitario,

		p_exento, p_descuento, p_importe);



    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_detalleventa` (IN `p_idproducto` INT(11), IN `p_cantidad` DECIMAL(13,2), IN `p_precio_unitario` DECIMAL(13,2), IN `p_exento` DECIMAL(13,2), IN `p_descuento` DECIMAL(13,2), IN `p_fecha_vence` DATE, IN `p_importe` DECIMAL(13,2))   BEGIN

	DECLARE p_idventa int(11);
    DECLARE p_idcomprobante int(11);
    DECLARE p_tipo_comprobante TINYINT(1);
	DECLARE p_comprobante	varchar(75);
    DECLARE p_precio_compra DECIMAL(13,2);
    DECLARE p_costo DECIMAL(13,2);
    DECLARE p_total DECIMAL(13,2);
    DECLARE p_numero_comprobante varchar(60);
    DECLARE p_descr_salida varchar(150);
    DECLARE p_inventariable int(11);
    DECLARE	p_estado tinyint(1);
    DECLARE p_stock DECIMAL(13,2);
    DECLARE p_cantidad_perecedero DECIMAL(13,2);

    SET p_idventa = (SELECT MAX(idventa) FROM venta);
    SET p_total = (SELECT total FROM venta WHERE idventa = p_idventa);
    SET p_precio_compra = (SELECT precio_compra FROM producto WHERE idproducto = p_idproducto);
    SET p_costo = (p_cantidad * p_precio_compra);
    SET p_tipo_comprobante = (SELECT tipo_comprobante FROM venta WHERE idventa = p_idventa);
    SET p_numero_comprobante = (SELECT numero_comprobante FROM venta WHERE idventa = p_idventa);
    SET p_comprobante = (SELECT nombre_comprobante FROM comprobante WHERE idcomprobante = p_tipo_comprobante);
    SET p_descr_salida = (CONCAT('POR VENTA',' ', p_comprobante,' # ',p_numero_comprobante));
    SET p_inventariable = (SELECT inventariable FROM producto WHERE idproducto = p_idproducto);
    SET p_estado = (SELECT estado FROM venta WHERE idventa = p_idventa);
    SET p_cantidad_perecedero = (SELECT cantidad_perecedero FROM perecedero WHERE idproducto = p_idproducto AND fecha_vencimiento = p_fecha_vence AND estado = 1);
    
    /*SET p_precio_unitario = (SELECT (sumas + descuento) FROM venta WHERE idventa = p_idventa) / p_cantidad;*/
    /*Linea agregada para cambio por precio seleccionado*/
    
    SET p_stock = (SELECT stock FROM producto WHERE idproducto = p_idproducto);
		IF (p_inventariable  = 0) THEN
			IF p_idventa IS NULL OR p_idventa = '' THEN

				INSERT INTO `detalleventa`(`idventa`, `idproducto`, `cantidad`, `precio_unitario`,
				`fecha_vence`, `exento`, `descuento`, `importe`)
				VALUES (1, p_idproducto, p_cantidad, p_precio_unitario,
				NULL, p_exento, p_descuento, p_importe);

				ELSE

				INSERT INTO `detalleventa`(`idventa`, `idproducto`, `cantidad`, `precio_unitario`,
				`fecha_vence`, `exento`, `descuento`, `importe`)
				VALUES (p_idventa, p_idproducto, p_cantidad, p_precio_unitario,
				NULL, p_exento, p_descuento, p_importe);

			END IF; 

		ELSE 

			IF (p_fecha_vence != '2000-01-01') THEN
				IF p_idventa IS NULL OR p_idventa = '' THEN
                    IF (p_stock > 0) THEN

							INSERT INTO `detalleventa`(`idventa`, `idproducto`, `cantidad`, `precio_unitario`,
							`fecha_vence`, `exento`, `descuento`, `importe`)
							VALUES (1, p_idproducto, p_cantidad, p_precio_unitario,
							p_fecha_vence, p_exento, p_descuento, p_importe);

							INSERT INTO `salida`(`mes_inventario`,`fecha_salida`, `descripcion_salida`, `cantidad_salida`,
							`precio_unitario_salida`, `costo_total_salida`,`idproducto`,`idventa`)
							VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),NOW(),p_descr_salida,p_cantidad,p_precio_compra,p_costo,p_idproducto,1);

							UPDATE `inventario` SET
							`saldo_final` = `saldo_final` - p_cantidad,
							`salidas` = `salidas` + p_cantidad
							WHERE idproducto = p_idproducto AND fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')
							AND fecha_cierre = LAST_DAY(CURDATE());

							CALL sp_descontar_perecedero(p_idproducto, p_cantidad, p_fecha_vence);

							UPDATE `producto` SET
							`stock` = `stock` - p_cantidad
							WHERE idproducto = p_idproducto;

                    END IF; 

			ELSE 

					 IF (p_stock > 0) THEN

							INSERT INTO `detalleventa`(`idventa`, `idproducto`, `cantidad`, `precio_unitario`,
							`fecha_vence`, `exento`, `descuento`, `importe`)
							VALUES (p_idventa, p_idproducto, p_cantidad, p_precio_unitario,
							p_fecha_vence, p_exento, p_descuento, p_importe);

							INSERT INTO `salida`(`mes_inventario`,`fecha_salida`, `descripcion_salida`, `cantidad_salida`,
							`precio_unitario_salida`, `costo_total_salida`,`idproducto`,`idventa`)
							VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),NOW(),p_descr_salida,p_cantidad,p_precio_compra,p_costo,p_idproducto,p_idventa);

							UPDATE `inventario` SET
							`saldo_final` = `saldo_final` - p_cantidad,
							`salidas` = `salidas` + p_cantidad
							WHERE idproducto = p_idproducto AND fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')
							AND fecha_cierre = LAST_DAY(CURDATE());

							CALL sp_descontar_perecedero(p_idproducto, p_cantidad, p_fecha_vence);

							UPDATE `producto` SET
							`stock` = `stock` - p_cantidad
							WHERE idproducto = p_idproducto;

						END IF; 

					END IF; 

				ELSE  

                IF p_idventa IS NULL OR p_idventa = '' THEN

                    IF (p_stock > 0) THEN

							INSERT INTO `detalleventa`(`idventa`, `idproducto`, `cantidad`, `precio_unitario`,
							`fecha_vence`, `exento`, `descuento`, `importe`)
							VALUES (1, p_idproducto, p_cantidad, p_precio_unitario,
							NULL, p_exento, p_descuento, p_importe);

							INSERT INTO `salida`(`mes_inventario`,`fecha_salida`, `descripcion_salida`, `cantidad_salida`,
							`precio_unitario_salida`, `costo_total_salida`,`idproducto`,`idventa`)
							VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),NOW(),p_descr_salida,p_cantidad,p_precio_compra,p_costo,p_idproducto,1);

							UPDATE `inventario` SET
							`saldo_final` = `saldo_final` - p_cantidad,
							`salidas` = `salidas` + p_cantidad
							WHERE idproducto = p_idproducto AND fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')
							AND fecha_cierre = LAST_DAY(CURDATE());

							/*UPDATE `producto` SET
							`stock` = `stock` - p_cantidad
							WHERE idproducto = p_idproducto;*/

                    END IF; 

			ELSE 

					 IF (p_stock > 0) THEN

							INSERT INTO `detalleventa`(`idventa`, `idproducto`, `cantidad`, `precio_unitario`,
							`fecha_vence`, `exento`, `descuento`, `importe`)
							VALUES (p_idventa, p_idproducto, p_cantidad, p_precio_unitario,
							NULL, p_exento, p_descuento, p_importe);

							INSERT INTO `salida`(`mes_inventario`,`fecha_salida`, `descripcion_salida`, `cantidad_salida`,
							`precio_unitario_salida`, `costo_total_salida`,`idproducto`,`idventa`)
							VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),NOW(),p_descr_salida,p_cantidad,p_precio_compra,p_costo,p_idproducto,p_idventa);

							UPDATE `inventario` SET
							`saldo_final` = `saldo_final` - p_cantidad,
							`salidas` = `salidas` + p_cantidad
							WHERE idproducto = p_idproducto AND fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')
							AND fecha_cierre = LAST_DAY(CURDATE());

							/*UPDATE `producto` SET
							`stock` = `stock` - p_cantidad
							WHERE idproducto = p_idproducto;*/



						END IF; 

					END IF; 

			END IF; 

		END IF;  

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_detalle_ordentaller` (IN `p_idorden` INT, IN `p_idproducto` INT, IN `p_precio` DECIMAL(13,2), IN `p_cantidad` INT)   BEGIN
   DECLARE DetalleCount INT;
   DECLARE cantidadPrev INT;
   SELECT COUNT(*) INTO DetalleCount FROM detalle_ordentaller WHERE idorden = p_idorden AND idproducto = p_idproducto;
    
   IF DetalleCount > 0 THEN
    
    UPDATE detalle_ordentaller
    SET precio = p_precio,
    cantidad = p_cantidad
    WHERE idorden = p_idorden AND idproducto = p_idproducto;
    
    SELECT cantidad INTO cantidadPrev FROM detalle_ordentaller WHERE idorden = p_idorden AND idproducto = p_idproducto;
    
    UPDATE producto 
    SET stock = stock + (cantidadPrev - p_cantidad)
    WHERE idproducto = p_idproducto;
    
    SELECT ROW_COUNT() AS registrosCount;
    
   ELSE
    
    INSERT INTO detalle_ordentaller (idorden, idproducto, precio, cantidad)
    VALUES (p_idorden, p_idproducto, p_precio, p_cantidad);
    
    UPDATE producto 
    SET stock = stock - p_cantidad
    WHERE idproducto = p_idproducto;
    
     -- Seleccionar el último ID insertado
    SELECT LAST_INSERT_ID() AS id_generado;
    
   END IF;  
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_diagnostico` (IN `p_idorden` INT(11), IN `p_diagnostico` VARCHAR(200), IN `p_estado_aparato` VARCHAR(200), IN `p_repuestos` DECIMAL(13,2), IN `p_mano_obra` DECIMAL(13,2), IN `p_fecha_alta` DATETIME, IN `p_fecha_retiro` DATETIME, IN `p_ubicacion` VARCHAR(150), IN `p_parcial_pagar` DECIMAL(13,2), IN `p_horaObra` INT)   BEGIN

	UPDATE `ordentaller`

	SET `diagnostico` = p_diagnostico, `estado_aparato` = p_estado_aparato,

    `repuestos` = p_repuestos, `mano_obra` = p_mano_obra, `fecha_alta` = p_fecha_alta,

    `fecha_retiro` = p_fecha_retiro, `ubicacion` = p_ubicacion, `parcial_pagar` = p_parcial_pagar, `horaObra` = p_horaObra

	WHERE `idorden` = p_idorden;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_empleado` (IN `p_nombre_empleado` VARCHAR(90), IN `p_apellido_empleado` VARCHAR(90), IN `p_telefono_empleado` VARCHAR(70), IN `p_email_empleado` VARCHAR(80), IN `p_image` VARCHAR(170))   BEGIN

	IF NOT EXISTS (SELECT * FROM `empleado` WHERE `nombre_empleado` = p_nombre_empleado AND

    `apellido_empleado` = p_apellido_empleado) THEN

		INSERT INTO `empleado`(`nombre_empleado`, `apellido_empleado`,

		`telefono_empleado`, `email_empleado`, `imagen`)

		VALUES (p_nombre_empleado, p_apellido_empleado,

		p_telefono_empleado, p_email_empleado, p_image);

	END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_entrada` (IN `p_descripcion_entrada` VARCHAR(150), IN `p_cantidad_entrada` DECIMAL(13,2), IN `p_idproducto` INT(11))   BEGIN



	DECLARE p_precio_unitario_entrada DECIMAL(13,2);

    DECLARE p_costo_total_entrada DECIMAL(13,2);



    SET p_precio_unitario_entrada = (SELECT precio_compra FROM producto WHERE idproducto = p_idproducto);

    SET p_costo_total_entrada = (p_precio_unitario_entrada * p_cantidad_entrada);



	INSERT INTO `entrada`(`mes_inventario`,`fecha_entrada`, `descripcion_entrada`, `cantidad_entrada`,

	`precio_unitario_entrada`, `costo_total_entrada`, `idproducto`, `idcompra`)

	VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),CURDATE(), p_descripcion_entrada, p_cantidad_entrada,

	p_precio_unitario_entrada, p_costo_total_entrada, p_idproducto, NULL);



	UPDATE `inventario` SET

	`saldo_final` = `saldo_final` + p_cantidad_entrada,

    `entradas` = `entradas` + p_cantidad_entrada

	WHERE idproducto = p_idproducto AND fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

	AND fecha_cierre = LAST_DAY(CURDATE());



	UPDATE `producto` SET

	`stock` = `stock` + p_cantidad_entrada

	WHERE idproducto = p_idproducto;





END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_marca` (IN `p_nombre_marca` VARCHAR(120))   BEGIN

  IF NOT EXISTS (SELECT * FROM `marca` WHERE `nombre_marca` = p_nombre_marca) THEN

	INSERT INTO `marca`(`nombre_marca`)

	VALUES (p_nombre_marca);

  END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_ordentaller` (IN `p_idcliente` INT(11), IN `p_aparato` VARCHAR(125), IN `p_modelo` VARCHAR(125), IN `p_idmarca` INT(11), IN `p_serie` VARCHAR(125), IN `p_idtecnico` INT(11), IN `p_averia` VARCHAR(200), IN `p_observaciones` VARCHAR(200), IN `p_deposito_revision` DECIMAL(13,2), IN `p_deposito_reparacion` DECIMAL(13,2), IN `p_parcial_pagar` DECIMAL(13,2), IN `p_repuesto` DECIMAL(13,2), IN `p_manoObra` DECIMAL(13,2), IN `p_HoraObra` INT, IN `p_AnioAuto` INT)   BEGIN
    INSERT INTO `ordentaller`(
        `fecha_ingreso`, `idcliente`,
        `aparato`, `modelo`, `idmarca`, `Placa`, `idtecnico`, `averia`, `observaciones`, `deposito_revision`,
        `deposito_reparacion`,`parcial_pagar`, `montoRepuesto`, `ManoObra`, `horaObra` , `AnioAuto`
    )
    VALUES (
        NOW(), p_idcliente,
        p_aparato, p_modelo, p_idmarca, p_serie,
        p_idtecnico, p_averia, p_observaciones, p_deposito_revision,
        p_deposito_reparacion, p_parcial_pagar, p_repuesto, p_manoObra, p_HoraObra, p_AnioAuto
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_parametro` (IN `p_nombre_empresa` VARCHAR(150), IN `p_propietario` VARCHAR(150), IN `p_numero_nit` VARCHAR(70), IN `p_numero_nrc` VARCHAR(70), IN `p_porcentaje_iva` DECIMAL(13,2), IN `p_porcentaje_retencion` DECIMAL(13,2), IN `p_monto_retencion` DECIMAL(13,2), IN `p_direccion_empresa` VARCHAR(200), IN `p_idcurrency` INT(11))   BEGIN

	   DECLARE contador INT;

	   SET contador = (SELECT COUNT(*) FROM `parametro`);



		IF contador = 0 THEN

			INSERT INTO `parametro`(`nombre_empresa`, `propietario`, `numero_nit`,

			`numero_nrc`, `porcentaje_iva`, `porcentaje_retencion`, `monto_retencion`, `direccion_empresa`,`idcurrency`)

			VALUES (p_nombre_empresa, p_propietario, p_numero_nit,

			p_numero_nrc, p_porcentaje_iva, p_porcentaje_retencion, p_monto_retencion,

            p_direccion_empresa,p_idcurrency);

		END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_perecedero` (IN `p_fecha_vencimiento` DATE, IN `p_cantidad_perecedero` DECIMAL(13,2), IN `p_idproducto` INT(11))   BEGIN

  IF NOT EXISTS (SELECT * FROM perecedero WHERE idproducto = p_idproducto

  AND fecha_vencimiento = p_fecha_vencimiento) THEN

	INSERT INTO `perecedero`(`fecha_vencimiento`, `cantidad_perecedero`, `idproducto`)

	VALUES (p_fecha_vencimiento, p_cantidad_perecedero, p_idproducto);

  END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_presentacion` (IN `p_nombre_presentacion` VARCHAR(120), IN `p_siglas` VARCHAR(45))   BEGIN

  IF NOT EXISTS (SELECT * FROM `presentacion` WHERE `nombre_presentacion` = p_nombre_presentacion) THEN

	INSERT INTO `presentacion`(`nombre_presentacion`,`siglas`)

	VALUES (p_nombre_presentacion,p_siglas);

  END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_producto` (IN `p_codigo_barra` VARCHAR(200), IN `p_codigo_alternativo` VARCHAR(200), IN `p_nombre_producto` VARCHAR(175), IN `p_precio_compra` DECIMAL(13,2), IN `p_precio_venta` DECIMAL(13,2), IN `p_precio_venta1` DECIMAL(13,2), IN `p_precio_venta2` DECIMAL(13,2), IN `p_precio_venta3` DECIMAL(13,2), IN `p_precio_venta_mayoreo` DECIMAL(13,2), IN `p_stock` DECIMAL(13,2), IN `p_stock_min` DECIMAL(13,2), IN `p_idcategoria` INT(11), IN `p_idmarca` INT(11), IN `p_idpresentacion` INT(11), IN `p_exento` TINYINT(1), IN `p_inventariable` TINYINT(1), IN `p_perecedero` TINYINT(1), IN `p_image` VARCHAR(170), IN `p_usuario` INT(11))   BEGIN



	IF (p_inventariable = 1) THEN



	 IF NOT EXISTS (SELECT * FROM `producto` WHERE `nombre_producto` = p_nombre_producto) THEN



		INSERT INTO `producto`(`codigo_barra`, `codigo_alternativo`, `nombre_producto`,

		`precio_compra`, `precio_venta`, `precio_venta1`, `precio_venta2`, `precio_venta3`, `precio_venta_mayoreo`, `stock`,

		`stock_min`, `idcategoria`, `idmarca`, `idpresentacion`,`exento`,

		`inventariable`, `perecedero`, `imagen`, `usuario`)

		VALUES (p_codigo_barra, p_codigo_alternativo, p_nombre_producto,

		p_precio_compra, p_precio_venta, p_precio_venta1, p_precio_venta2, p_precio_venta3, p_precio_venta_mayoreo,p_stock,

		p_stock_min, p_idcategoria, p_idmarca, p_idpresentacion,

		p_exento, p_inventariable, p_perecedero, p_image, p_usuario);

	 END IF;



     ELSE



		IF NOT EXISTS (SELECT * FROM `producto` WHERE `nombre_producto` = p_nombre_producto) THEN



			INSERT INTO `producto`(`codigo_barra`, `codigo_alternativo`, `nombre_producto`,

			`precio_compra`, `precio_venta`, `precio_venta1`, `precio_venta2`, `precio_venta3`, `precio_venta_mayoreo`,

			`stock_min`, `idcategoria`, `idmarca`, `idpresentacion`,`exento`,

			`inventariable`, `perecedero`, `imagen`, `usuario`)

			VALUES (p_codigo_barra, p_codigo_alternativo, p_nombre_producto,

			p_precio_compra, p_precio_venta, p_precio_venta1, p_precio_venta2, p_precio_venta3, p_precio_venta_mayoreo,

			0, p_idcategoria, p_idmarca, p_idpresentacion,

			p_exento, p_inventariable, p_perecedero, p_image, p_usuario);

		 END IF;



   END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_proveedor` (IN `p_nombre_proveedor` VARCHAR(175), IN `p_numero_telefono` VARCHAR(70), IN `p_numero_nit` VARCHAR(70), IN `p_numero_nrc` VARCHAR(70), IN `p_nombre_contacto` VARCHAR(150), IN `p_telefono_contacto` VARCHAR(150), IN `Correo` VARCHAR(50), IN `Direccion` VARCHAR(250), IN `Comentario` VARCHAR(500))   BEGIN

   IF NOT EXISTS (SELECT * FROM `proveedor` WHERE `nombre_proveedor` = p_nombre_proveedor OR `numero_nrc` =  p_numero_nrc) THEN

                INSERT INTO `proveedor`(`nombre_proveedor`, `numero_telefono`,

                `numero_nit`, `numero_nrc`, `nombre_contacto`, `telefono_contacto`, `Correo`, `Direccion`, `Comentario`)

                VALUES (p_nombre_proveedor, p_numero_telefono,

                p_numero_nit, p_numero_nrc, p_nombre_contacto, p_telefono_contacto, Correo, Direccion, Comentario);

   END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_salida` (IN `p_descripcion_salida` VARCHAR(150), IN `p_cantidad_salida` DECIMAL(13,2), IN `p_idproducto` INT(11))   BEGIN



	DECLARE p_precio_unitario_salida DECIMAL(13,2);

	DECLARE p_costo_total_salida DECIMAL(13,2);



	SET p_precio_unitario_salida = (SELECT precio_compra FROM producto WHERE idproducto = p_idproducto);

	SET p_costo_total_salida = (p_precio_unitario_salida * p_cantidad_salida);



	INSERT INTO `salida`(`mes_inventario`,`fecha_salida`, `descripcion_salida`, `cantidad_salida`,

	`precio_unitario_salida`, `costo_total_salida`, `idproducto`, `idventa`)

	VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),CURDATE(), p_descripcion_salida, p_cantidad_salida,

	p_precio_unitario_salida, p_costo_total_salida, p_idproducto, NULL);



	UPDATE `inventario` SET

	`saldo_final` = `saldo_final` - p_cantidad_salida,

    `salidas` = `salidas` + p_cantidad_salida

	WHERE idproducto = p_idproducto AND fecha_apertura =  DATE_FORMAT(CURDATE(),'%Y-%m-01')

	AND fecha_cierre = LAST_DAY(CURDATE());



	UPDATE `producto` SET

	`stock` = `stock` - p_cantidad_salida

	WHERE idproducto = p_idproducto;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_tecnico` (IN `p_tecnico` VARCHAR(150), IN `p_telefono` VARCHAR(70))   BEGIN

 IF NOT EXISTS (SELECT * FROM tecnico WHERE tecnico = p_tecnico) THEN

	INSERT INTO `tecnico`(`tecnico`, `telefono`)

	VALUES (p_tecnico, p_telefono);

 END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_tiraje_comprobante` (IN `p_fecha_resolucion` DATETIME, IN `p_numero_resolucion` VARCHAR(100), IN `p_serie` VARCHAR(175), IN `p_desde` INT(11), IN `p_hasta` INT(11), IN `p_disponibles` INT(11), IN `p_idcomprobante` INT(11))   BEGIN

   IF NOT EXISTS (SELECT * FROM `tiraje_comprobante` WHERE idcomprobante =  p_idcomprobante) THEN

	 INSERT INTO `tiraje_comprobante`(`fecha_resolucion`, `numero_resolucion`, `serie`,

	`desde`, `hasta`, `disponibles`, `idcomprobante`)

		VALUES (p_fecha_resolucion, p_numero_resolucion, p_serie,

		p_desde, p_hasta, p_disponibles, p_idcomprobante);

   END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_usuario` (IN `p_usuario` VARCHAR(70), IN `p_contrasena` VARCHAR(180), IN `p_tipo_usuario` TINYINT(1), IN `p_idempleado` INT(11))   BEGIN

  IF NOT EXISTS (SELECT * FROM `usuario` WHERE `idempleado` = p_idempleado) THEN

	INSERT INTO `usuario`(`usuario`, `contrasena`, `tipo_usuario`,`idempleado`)

	VALUES (p_usuario, p_contrasena, p_tipo_usuario, p_idempleado);

  END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_venta` (IN `p_tipo_pago` VARCHAR(75), IN `p_tipo_comprobante` TINYINT(1), IN `p_sumas` DECIMAL(13,2), IN `p_iva` DECIMAL(13,2), IN `p_exento` DECIMAL(13,2), IN `p_retenido` DECIMAL(13,2), IN `p_descuento` DECIMAL(13,2), IN `p_total` DECIMAL(13,2), IN `p_sonletras` VARCHAR(150), IN `p_pago_efectivo` DECIMAL(13,2), IN `p_pago_tarjeta` DECIMAL(13,2), IN `p_numero_tarjeta` VARCHAR(16), IN `p_tarjeta_habiente` VARCHAR(90), IN `p_cambio` DECIMAL(13,2), IN `p_estado` TINYINT(1), IN `p_idcliente` INT(11), IN `p_idusuario` INT(11), IN `p_tipoVenta` INT(11))   BEGIN



	DECLARE p_numero_comprobante INT;

    DECLARE p_efectivo_caja DECIMAL(13,2);

    DECLARE p_abono_credito DECIMAL(13,2);

	SET p_numero_comprobante = (SELECT usados + 1 FROM view_comprobantes WHERE idcomprobante = p_tipo_comprobante);







		  IF NOT EXISTS (SELECT * FROM venta WHERE `numero_comprobante` = p_numero_comprobante

		  AND `tipo_comprobante` = p_tipo_comprobante AND `fecha_venta` = NOW()) THEN



			  IF p_estado = '1' THEN



              IF p_idcliente = '0' THEN



			    IF p_numero_comprobante = '0' THEN



					INSERT INTO `venta`(`fecha_venta`, `tipo_pago`,

					`numero_comprobante`, `tipo_comprobante`, `sumas`, `iva`,

					`exento`, `retenido`, `descuento`, `total`,

					`sonletras`, `pago_efectivo`, `pago_tarjeta`, `numero_tarjeta`,

					`tarjeta_habiente`, `cambio`, `estado`, `idcliente`, `idusuario` , `tipoVenta`)

					VALUES (NOW(), p_tipo_pago,

					1, p_tipo_comprobante, p_sumas, p_iva,

					p_exento, p_retenido, p_descuento, p_total,

					p_sonletras, p_pago_efectivo, p_pago_tarjeta, p_numero_tarjeta,

					p_tarjeta_habiente, p_cambio, p_estado, NULL, p_idusuario, p_tipoVenta);

                    

					UPDATE `tiraje_comprobante` SET

					`disponibles` = `disponibles` - 1

					WHERE idcomprobante = p_tipo_comprobante;





					/*IF (p_tipo_pago = 'EFECTIVO') THEN

						CALL sp_insert_caja_venta(p_total);

					ELSEIF (p_tipo_pago = 'EFECTIVO Y TARJETA') THEN

						CALL sp_insert_caja_venta(p_pago_efectivo);

					END IF;*/



				ELSE



					INSERT INTO `venta`(`fecha_venta`, `tipo_pago`,

					`numero_comprobante`, `tipo_comprobante`, `sumas`, `iva`,

					`exento`, `retenido`, `descuento`, `total`,

					`sonletras`, `pago_efectivo`, `pago_tarjeta`, `numero_tarjeta`,

					`tarjeta_habiente`, `cambio`, `estado`, `idcliente`, `idusuario`, `tipoVenta`)

					VALUES (NOW(), p_tipo_pago,

					p_numero_comprobante, p_tipo_comprobante, p_sumas, p_iva,

					p_exento, p_retenido, p_descuento, p_total,

					p_sonletras, p_pago_efectivo, p_pago_tarjeta, p_numero_tarjeta,

					p_tarjeta_habiente, p_cambio, p_estado, NULL, p_idusuario, p_tipoVenta);

                    

					UPDATE `tiraje_comprobante` SET

					`disponibles` = `disponibles` - 1

					WHERE idcomprobante = p_tipo_comprobante;





					/*IF (p_tipo_pago = 'EFECTIVO') THEN

						CALL sp_insert_caja_venta(p_total);

					ELSEIF (p_tipo_pago = 'EFECTIVO Y TARJETA') THEN

						CALL sp_insert_caja_venta(p_pago_efectivo);

					END IF;*/



				END IF;



			   ELSE



				IF p_numero_comprobante = '0' THEN



					INSERT INTO `venta`(`fecha_venta`, `tipo_pago`,

					`numero_comprobante`, `tipo_comprobante`, `sumas`, `iva`,

					`exento`, `retenido`, `descuento`, `total`,

					`sonletras`, `pago_efectivo`, `pago_tarjeta`, `numero_tarjeta`,

					`tarjeta_habiente`, `cambio`, `estado`, `idcliente`, `idusuario`, `tipoVenta`)

					VALUES (NOW(), p_tipo_pago,

					1, p_tipo_comprobante, p_sumas, p_iva,

					p_exento, p_retenido, p_descuento, p_total,

					p_sonletras, p_pago_efectivo, p_pago_tarjeta, p_numero_tarjeta,

					p_tarjeta_habiente, p_cambio, p_estado, p_idcliente, p_idusuario, p_tipoVenta);

                    

					UPDATE `tiraje_comprobante` SET

					`disponibles` = `disponibles` - 1

					WHERE idcomprobante = p_tipo_comprobante;





					/*IF (p_tipo_pago = 'EFECTIVO') THEN

						CALL sp_insert_caja_venta(p_total);

					ELSEIF (p_tipo_pago = 'EFECTIVO Y TARJETA') THEN

						CALL sp_insert_caja_venta(p_pago_efectivo);

					END IF;*/



				ELSE




					INSERT INTO `venta`(`fecha_venta`, `tipo_pago`,

					`numero_comprobante`, `tipo_comprobante`, `sumas`, `iva`,

					`exento`, `retenido`, `descuento`, `total`,

					`sonletras`, `pago_efectivo`, `pago_tarjeta`, `numero_tarjeta`,

					`tarjeta_habiente`, `cambio`, `estado`, `idcliente`, `idusuario`, `tipoVenta`)

					VALUES (NOW(), p_tipo_pago,

					p_numero_comprobante, p_tipo_comprobante, p_sumas, p_iva,

					p_exento, p_retenido, p_descuento, p_total,

					p_sonletras, p_pago_efectivo, p_pago_tarjeta, p_numero_tarjeta,

					p_tarjeta_habiente, p_cambio, p_estado, p_idcliente, p_idusuario, p_tipoVenta);

                    

					UPDATE `tiraje_comprobante` SET

					`disponibles` = `disponibles` - 1

					WHERE idcomprobante = p_tipo_comprobante;





					/*IF (p_tipo_pago = 'EFECTIVO') THEN

						CALL sp_insert_caja_venta(p_total);

					ELSEIF (p_tipo_pago = 'EFECTIVO Y TARJETA') THEN

						CALL sp_insert_caja_venta(p_pago_efectivo);

					END IF;*/



				END IF;





			  END IF;





            ELSEIF p_estado = '2' THEN



            IF p_numero_comprobante = '0' THEN



				INSERT INTO `venta`(`fecha_venta`, `tipo_pago`,

				`numero_comprobante`, `tipo_comprobante`, `sumas`, `iva`,

				`exento`, `retenido`, `descuento`, `total`,

				`sonletras`, `pago_efectivo`, `pago_tarjeta`, `numero_tarjeta`,

				`tarjeta_habiente`, `cambio`, `estado`, `idcliente`, `idusuario`, `tipoVenta`)

				VALUES (NOW(), p_tipo_pago,

				1, p_tipo_comprobante, p_sumas, p_iva,

				p_exento, p_retenido, p_descuento, p_total,

				p_sonletras, 0.00, 0.00, NULL, 0.00, 0.00, p_estado, p_idcliente, p_idusuario, p_tipoVenta);



				UPDATE `tiraje_comprobante` SET

				`disponibles` = `disponibles` - 1

				WHERE idcomprobante = p_tipo_comprobante;



                CALL sp_insert_credito_venta(p_total, p_idcliente);



                ELSE



				INSERT INTO `venta`(`fecha_venta`, `tipo_pago`,

				`numero_comprobante`, `tipo_comprobante`, `sumas`, `iva`,


				`exento`, `retenido`, `descuento`, `total`,

				`sonletras`, `pago_efectivo`, `pago_tarjeta`, `numero_tarjeta`,

				`tarjeta_habiente`, `cambio`, `estado`, `idcliente`, `idusuario`, `tipoVenta`)

				VALUES (NOW(), p_tipo_pago,

				p_numero_comprobante, p_tipo_comprobante, p_sumas, p_iva,

				p_exento, p_retenido, p_descuento, p_total,

				p_sonletras, 0.00, 0.00, NULL, 0.00, 0.00, p_estado, p_idcliente, p_idusuario, p_tipoVenta);



				UPDATE `tiraje_comprobante` SET

				`disponibles` = `disponibles` - 1

				WHERE idcomprobante = p_tipo_comprobante;



                CALL sp_insert_credito_venta(p_total, p_idcliente);



			END IF;



			END IF;



		END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_venta_apartado` (IN `p_idapartado` INT(11), IN `p_tipo_pago` VARCHAR(75), IN `p_tipo_comprobante` TINYINT(1), IN `p_pago_efectivo` DECIMAL(13,2), IN `p_pago_tarjeta` DECIMAL(13,2), IN `p_numero_tarjeta` VARCHAR(16), IN `p_tarjeta_habiente` VARCHAR(90), IN `p_cambio` DECIMAL(13,2), IN `p_idcliente` INT(11), IN `p_idusuario` INT(11))   BEGIN



	DECLARE p_numero_comprobante INT;

    DECLARE p_abono_credito DECIMAL(13,2);

    DECLARE p_idventa INT;

    DECLARE p_sumas DECIMAL(13,2);

  	DECLARE p_iva DECIMAL(13,2);

  	DECLARE p_exento DECIMAL(13,2);

  	DECLARE p_retenido DECIMAL(13,2);

  	DECLARE p_descuento DECIMAL(13,2);

  	DECLARE p_total DECIMAL(13,2);

  	DECLARE p_sonletras varchar(150);



  	SET p_numero_comprobante = (SELECT usados + 1 FROM view_comprobantes WHERE idcomprobante = p_tipo_comprobante);

    SET p_sumas = (SELECT sumas FROM apartado WHERE idapartado = p_idapartado);

    SET p_iva = (SELECT iva FROM apartado WHERE idapartado = p_idapartado);

    SET p_exento = (SELECT exento FROM apartado WHERE idapartado = p_idapartado);

    SET p_retenido = (SELECT retenido FROM apartado WHERE idapartado = p_idapartado);

    SET p_descuento = (SELECT descuento FROM apartado WHERE idapartado = p_idapartado);

    SET p_total = (SELECT total FROM apartado WHERE idapartado = p_idapartado);

    SET p_sonletras = (SELECT sonletras FROM apartado WHERE idapartado = p_idapartado);





		  IF NOT EXISTS (SELECT * FROM venta WHERE `numero_comprobante` = p_numero_comprobante

		  AND `tipo_comprobante` = p_tipo_comprobante AND `fecha_venta` = NOW()) THEN





				IF p_numero_comprobante = '0' THEN



					INSERT INTO `venta`(`fecha_venta`, `tipo_pago`,

					`numero_comprobante`, `tipo_comprobante`, `sumas`, `iva`,

					`exento`, `retenido`, `descuento`, `total`,

					`sonletras`, `pago_efectivo`, `pago_tarjeta`, `numero_tarjeta`,

					`tarjeta_habiente`, `cambio`, `estado`, `idcliente`, `idusuario`)

					VALUES (NOW(), p_tipo_pago,

					1, p_tipo_comprobante, p_sumas, p_iva,

					p_exento, p_retenido, p_descuento, p_total,

					p_sonletras, p_pago_efectivo, p_pago_tarjeta, p_numero_tarjeta,

					p_tarjeta_habiente, p_cambio, 1, NULL, p_idusuario);

                    

					UPDATE `tiraje_comprobante` SET

					`disponibles` = `disponibles` - 1

					WHERE idcomprobante = p_tipo_comprobante;





					IF (p_tipo_pago = 'EFECTIVO') THEN

						CALL sp_insert_caja_venta(p_total);

					ELSEIF (p_tipo_pago = 'EFECTIVO Y TARJETA') THEN

						CALL sp_insert_caja_venta(p_pago_efectivo);

					END IF;



				ELSE



					INSERT INTO `venta`(`fecha_venta`, `tipo_pago`,

					`numero_comprobante`, `tipo_comprobante`, `sumas`, `iva`,

					`exento`, `retenido`, `descuento`, `total`,

					`sonletras`, `pago_efectivo`, `pago_tarjeta`, `numero_tarjeta`,

					`tarjeta_habiente`, `cambio`, `estado`, `idcliente`, `idusuario`)

					VALUES (NOW(), p_tipo_pago,

					p_numero_comprobante, p_tipo_comprobante, p_sumas, p_iva,

					p_exento, p_retenido, p_descuento, p_total,

					p_sonletras, p_pago_efectivo, p_pago_tarjeta, p_numero_tarjeta,

					p_tarjeta_habiente, p_cambio, 1, NULL, p_idusuario);

                    

					UPDATE `tiraje_comprobante` SET

					`disponibles` = `disponibles` - 1

					WHERE idcomprobante = p_tipo_comprobante;





					IF (p_tipo_pago = 'EFECTIVO') THEN

						CALL sp_insert_caja_venta(p_total);

					ELSEIF (p_tipo_pago = 'EFECTIVO Y TARJETA') THEN

						CALL sp_insert_caja_venta(p_pago_efectivo);

					END IF;



				END IF;



				UPDATE `apartado` SET

				`estado` = 2

				WHERE idapartado = p_idapartado;



                SET p_idventa = (SELECT MAX(idventa) FROM venta);



				INSERT INTO `detalleventa`(`idventa`, `idproducto`, `cantidad`, `precio_unitario`, `fecha_vence`,

                `exento`, `descuento`, `importe`)

				SELECT p_idventa, idproducto,cantidad,precio_unitario,fecha_vence,exento,descuento,importe FROM detalleapartado

				WHERE idapartado = p_idapartado;



		END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_kardex_inventario` (IN `p_mes` VARCHAR(7))   BEGIN



	IF p_mes = '' THEN



        SELECT * FROM view_kardex WHERE mes_inventario = DATE_FORMAT(CURDATE(),'%Y-%m')

        ORDER BY idproducto;



	 ELSE



		SELECT * FROM view_kardex WHERE mes_inventario = p_mes  ORDER BY idproducto;



    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login_usuario` (IN `p_usuario` VARCHAR(70), IN `p_contrasena` VARCHAR(180))   BEGIN

	SELECT * FROM view_usuarios WHERE usuario = p_usuario AND contrasena = p_contrasena

    AND estado = 1;



    CALL sp_cerrar_inventario();



    CALL sp_sacar_vencidos();

    

    CALL sp_devolver_productos_apartados();



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_panel_dashboard` ()   BEGIN



	DECLARE compras_mes DECIMAL(13,2);

	DECLARE ventas_dia DECIMAL(13,2);

	DECLARE inversion_stock DECIMAL(13,2);

	DECLARE proveedores DECIMAL(13,2);

	DECLARE marcas DECIMAL(13,2);

	DECLARE presentaciones DECIMAL(13,2);

	DECLARE productos DECIMAL(13,2);

	DECLARE a_vencer DECIMAL(13,2);

    DECLARE perecederos DECIMAL(13,2);

	DECLARE clientes DECIMAL(13,2);

    DECLARE creditos DECIMAL(13,2);

	DECLARE p_ingresos DECIMAL(13,2);

	DECLARE p_devoluciones DECIMAL(13,2);

	DECLARE p_prestamos DECIMAL(13,2);

	DECLARE p_gastos DECIMAL(13,2);

	DECLARE p_egresos DECIMAL(13,2);

	DECLARE p_saldo DECIMAL(13,2);



    DECLARE p_monto_inicial DECIMAL(13,2);





    SET p_ingresos = (SELECT SUM(monto_movimiento) FROM view_caja WHERE

    DATE(fecha_apertura) = CURDATE() AND tipo_movimiento = 1);



    SET p_devoluciones = (SELECT SUM(monto_movimiento) FROM view_caja WHERE

    DATE(fecha_apertura) = CURDATE() AND tipo_movimiento = 2);



    SET p_prestamos = (SELECT SUM(monto_movimiento) FROM view_caja WHERE

    DATE(fecha_apertura) = CURDATE() AND tipo_movimiento = 3);



    SET p_gastos = (SELECT SUM(monto_movimiento) FROM view_caja WHERE

    DATE(fecha_apertura) = CURDATE() AND tipo_movimiento = 4);



	IF (p_ingresos IS NULL) THEN

	   SET p_ingresos = (0.00);

	END IF;



	IF (p_devoluciones IS NULL) THEN

	   SET p_devoluciones = (0.00);

	END IF;



	IF (p_gastos IS NULL) THEN

	   SET p_gastos = (0.00);

	END IF;



	IF (p_prestamos IS NULL) THEN

	   SET p_prestamos = (0.00);

	END IF;



    SET p_egresos = (p_prestamos + p_gastos);

    SET p_saldo = (p_ingresos - p_egresos +  p_devoluciones);

    SET p_monto_inicial = (SELECT monto_apertura FROM caja WHERE DATE(fecha_apertura) = CURDATE());



	SET compras_mes = (SELECT if(SUM(total) IS NULL,0.00,SUM(total)) as compras_mes

    FROM compra  WHERE MONTH(fecha_compra) = MONTH(NOW()) AND estado=1);

    SET ventas_dia = (SELECT if(SUM(total) IS NULL,0.00, SUM(total)) as ventas_dia

    FROM venta  WHERE DATE_FORMAT(fecha_venta,'%Y-%m-%d') = CURDATE() AND estado = 1);

    SET inversion_stock = (SELECT TRUNCATE(SUM((stock * precio_compra)),2) as costo FROM producto

    WHERE  stock > 0.00);

    SET proveedores = (SELECT COUNT(*) as numero_proveedores FROM proveedor);

    SET marcas = (SELECT COUNT(*) as numero_marcas FROM marca);

    SET presentaciones = (SELECT COUNT(*) as numero_presentaciones FROM presentacion);

    SET productos = (SELECT COUNT(*) as numero_productos FROM producto);



    SET a_vencer = (SELECT COUNT(*) FROM perecedero WHERE fecha_vencimiento

    BETWEEN CURDATE() + INTERVAL 30 DAY AND CURDATE() + INTERVAL 1 MONTH);



    SET perecederos = (SELECT COUNT(*) FROM perecedero);

    SET clientes = (SELECT COUNT(*) FROM cliente);

    SET creditos = (SELECT COUNT(*) FROM credito WHERE estado = 0);





    SELECT compras_mes,ventas_dia,inversion_stock,proveedores,marcas,presentaciones,productos,

    p_monto_inicial + p_saldo as dinero_caja, perecederos, a_vencer,clientes,creditos;





END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_print_barcode_producto` (IN `p_id` INT)   BEGIN

SELECT codigo_barra,codigo_alternativo,codigo_interno,nombre_producto FROM producto WHERE idproducto = p_id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_sacar_vencidos` ()   BEGIN



		UPDATE `perecedero` SET

		`estado` = 0 WHERE `estado` = 1

         AND fecha_vencimiento < CURDATE();



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_search_producto` (IN `p_search` VARCHAR(175))   BEGIN

SELECT idproducto,codigo_interno,codigo_barra,codigo_alternativo,nombre_producto,siglas,nombre_marca,

precio_compra,exento,perecedero FROM view_productos WHERE codigo_barra LIKE CONCAT('%',p_search,'%')

OR codigo_interno LIKE CONCAT('%',p_search,'%')

OR codigo_alternativo LIKE CONCAT('%',p_search,'%')

OR nombre_producto LIKE CONCAT('%',p_search,'%') AND estado = 1 AND inventariable = 1 AND precio_compra > 0.00;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_search_producto_apartado` (IN `p_search` VARCHAR(175))   BEGIN

SELECT * FROM view_productos_apartado WHERE codigo_barra LIKE CONCAT('%',p_search,'%')

OR nombre_producto LIKE CONCAT('%',p_search,'%') OR codigo_interno LIKE CONCAT('%',p_search,'%')

OR codigo_alternativo LIKE CONCAT('%',p_search,'%')

ORDER BY idproducto DESC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_search_producto_cotizacion` (IN `p_search` VARCHAR(175))   BEGIN

SELECT idproducto,codigo_interno,codigo_barra,codigo_alternativo,nombre_producto,siglas,nombre_marca,

precio_venta,precio_venta_mayoreo,stock,exento,perecedero

FROM view_productos WHERE codigo_barra LIKE CONCAT('%',p_search,'%')

OR codigo_alternativo LIKE CONCAT('%',p_search,'%')

OR codigo_interno LIKE CONCAT('%',p_search,'%')

OR nombre_producto LIKE CONCAT('%',p_search,'%') AND estado = 1 AND inventariable = 1

AND precio_venta > 0.00;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_search_producto_venta` (IN `p_search` VARCHAR(175))   BEGIN

SELECT * FROM view_productos_venta WHERE codigo_interno LIKE CONCAT('%',p_search,'%')
OR codigo_barra LIKE CONCAT('%',p_search,'%')
OR codigo_alternativo LIKE CONCAT('%',p_search,'%')
OR nombre_producto LIKE CONCAT('%',p_search,'%')

ORDER BY idproducto DESC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateCotizaFact` (IN `P_IdCotizacion` INT)   BEGIN  
-- Actualizar la cotizacion
  
    DECLARE ultimo_idVenta INT;

    SELECT idventa INTO ultimo_idVenta
    FROM venta
    ORDER BY idventa DESC
    LIMIT 1;
  
  
    UPDATE cotizacion
    SET 
        idventa = ultimo_idVenta
    WHERE idcotizacion = P_IdCotizacion;
	
	SELECT idcotizacion from cotizacion 
	WHERE idcotizacion = P_IdCotizacion;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateVentaFactura` (IN `p_IdVenta` INT, IN `p_tipo_pago` VARCHAR(75), IN `p_tipo_comprobante` INT, IN `p_pago_efectivo` DECIMAL(13,2), IN `p_pago_tarjeta` DECIMAL(13,2), IN `p_numero_tarjeta` DECIMAL(13,2), IN `p_tarjeta_habiente` DECIMAL(13,2), IN `p_cambio` DECIMAL(13,2), IN `p_idusuario` INT, IN `p_tipoVenta` INT)   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_idProducto INT;
    DECLARE v_cantidad INT;
    DECLARE rows_affected INT DEFAULT 0; -- Inicializa en 0
    DECLARE cur CURSOR FOR 
        SELECT idproducto, cantidad 
        FROM detalleventa 
        WHERE idventa = p_IdVenta;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Actualizar la venta
    UPDATE venta
    SET 
        fecha_factura = NOW(),
        tipo_pago = p_tipo_pago,
        tipo_comprobante = p_tipo_comprobante,
        pago_efectivo = p_pago_efectivo,
        pago_tarjeta = p_pago_tarjeta,
        numero_tarjeta = p_numero_tarjeta,
        tarjeta_habiente = p_tarjeta_habiente,
        cambio = p_cambio,
        idUserCajero = p_idusuario,
        facturado = 1, 
        tipoVenta = p_tipoVenta
    WHERE idventa = p_IdVenta;

    -- Abrir el cursor
    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_idProducto, v_cantidad;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Actualizar el stock del producto
        UPDATE producto
        SET stock = stock - v_cantidad
        WHERE idproducto = v_idProducto;

        -- Incrementar el contador de filas afectadas
        SET rows_affected = rows_affected + ROW_COUNT(); -- Contar filas afectadas
    END LOOP;

    -- Cerrar el cursor
    CLOSE cur;

    -- Seleccionar el conteo de registros actualizados
    SELECT rows_affected AS updated_rows;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_abono` (IN `p_idabono` INT(11), IN `p_fecha_abono` DATETIME, IN `p_monto_abono` DECIMAL(13,2))   BEGIN

UPDATE `abono`

SET  `fecha_abono` = p_fecha_abono, `monto_abono` = p_monto_abono

WHERE `idabono` = p_idabono;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_categoria` (IN `p_idcategoria` INT(11), IN `p_nombre_categoria` VARCHAR(120), IN `p_estado` TINYINT(1))   BEGIN

UPDATE `categoria`

SET `nombre_categoria` = p_nombre_categoria, `estado` = p_estado

WHERE `idcategoria` = p_idcategoria;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_cliente` (IN `p_idcliente` INT(11), IN `p_nombre_cliente` VARCHAR(150), IN `p_numero_nit` VARCHAR(70), IN `p_numero_nrc` VARCHAR(45), IN `p_direccion_cliente` VARCHAR(100), IN `p_numero_telefono` VARCHAR(70), IN `p_email` VARCHAR(80), IN `p_giro` VARCHAR(80), IN `p_limite_credito` DECIMAL(13,2), IN `p_estado` TINYINT(1), IN `p_dias_pagar` INT(5))   BEGIN

UPDATE `cliente`

SET  `nombre_cliente` = p_nombre_cliente, `numero_nit` = p_numero_nit, `numero_nrc` = p_numero_nrc,

`direccion_cliente` = p_direccion_cliente, `numero_telefono` = p_numero_telefono, `email` = p_email,

`giro` = p_giro, `limite_credito` = p_limite_credito,

`estado` = p_estado, `iddias` = p_dias_pagar

WHERE `idcliente` = p_idcliente;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_comprobante` (IN `p_idcomprobante` INT(11), IN `p_nombre_comprobante` VARCHAR(75), IN `p_estado` TINYINT(1))   BEGIN

UPDATE `comprobante`

SET `nombre_comprobante` = p_nombre_comprobante, `estado` = p_estado

WHERE `idcomprobante` = p_idcomprobante;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_credito` (IN `p_idcredito` INT(11), IN `p_nombre_credito` VARCHAR(120), IN `p_fecha_credito` DATETIME, IN `p_monto_credito` DECIMAL(13,2), IN `p_monto_abonado` DECIMAL(13,2), IN `p_monto_restante` DECIMAL(13,2), IN `p_estado` TINYINT(1))   BEGIN

UPDATE `credito`

SET `nombre_credito` = p_nombre_credito, `fecha_credito` = p_fecha_credito,

`monto_credito` = p_monto_credito, `monto_abonado` = p_monto_abonado, `monto_restante` = p_monto_restante,

`estado` = p_estado

WHERE `idcredito` = p_idcredito;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_currency` (IN `p_idcurrency` INT(11), IN `p_CurrencyISO` VARCHAR(3), IN `p_Language` VARCHAR(3), IN `p_CurrencyName` VARCHAR(35), IN `p_Money` VARCHAR(30), IN `p_Symbol` VARCHAR(3))   BEGIN

UPDATE `currency` 

SET `CurrencyISO` = p_CurrencyISO, `Language` = p_Language, `CurrencyName` = p_CurrencyName, `Money` = p_Money, 

`Symbol` = p_Symbol

WHERE `idcurrency` = p_idcurrency;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_empleado` (IN `p_idempleado` INT(11), IN `p_nombre_empleado` VARCHAR(90), IN `p_apellido_empleado` VARCHAR(90), IN `p_telefono_empleado` VARCHAR(70), IN `p_email_empleado` VARCHAR(80), IN `p_estado` TINYINT(1), IN `p_image` VARCHAR(170))   BEGIN

UPDATE `empleado`

SET `nombre_empleado` = p_nombre_empleado, `apellido_empleado` = p_apellido_empleado, `telefono_empleado` = p_telefono_empleado,

`email_empleado` = p_email_empleado, `estado` = p_estado, `imagen` = p_image

WHERE `idempleado` = p_idempleado;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_marca` (IN `p_idmarca` INT(11), IN `p_nombre_marca` VARCHAR(120), IN `p_estado` TINYINT(1))   BEGIN

UPDATE `marca`

SET `nombre_marca` = p_nombre_marca, `estado` = p_estado

WHERE `idmarca` = p_idmarca;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_monto_inicial` (IN `p_monto_apertura` DECIMAL(13,2))   BEGIN

	IF EXISTS (SELECT * FROM `caja` WHERE DATE_FORMAT(`fecha_apertura`,'%Y-%m-%d') = curdate()) THEN

		UPDATE `caja` SET

        `monto_apertura` =  p_monto_apertura

		WHERE DATE_FORMAT(`fecha_apertura`,'%Y-%m-%d') = curdate();

	END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_ordentaller` (IN `p_idorden` INT(11), IN `p_numero_orden` VARCHAR(175), IN `p_fecha_ingreso` DATETIME, IN `p_idcliente` INT(11), IN `p_aparato` VARCHAR(125), IN `p_modelo` VARCHAR(125), IN `p_idmarca` INT(11), IN `p_serie` VARCHAR(125), IN `p_idtecnico` INT(11), IN `p_averia` VARCHAR(200), IN `p_observaciones` VARCHAR(200), IN `p_deposito_revision` DECIMAL(13,2), IN `p_deposito_reparacion` DECIMAL(13,2), IN `p_diagnostico` VARCHAR(200), IN `p_estado_aparato` VARCHAR(200), IN `p_repuestos` DECIMAL(13,2), IN `p_mano_obra` DECIMAL(13,2), IN `p_fecha_alta` DATETIME, IN `p_fecha_retiro` DATETIME, IN `p_ubicacion` VARCHAR(150), IN `p_parcial_pagar` DECIMAL(13,2))   BEGIN

UPDATE `ordentaller`

SET `numero_orden` = p_numero_orden, `fecha_ingreso` = p_fecha_ingreso, `idcliente` = p_idcliente, `aparato` = p_aparato,

`modelo` = p_modelo, `idmarca` = p_idmarca, `serie` = p_serie, `idtecnico` = p_idtecnico,

`averia` = p_averia, `observaciones` = p_observaciones, `deposito_revision` = p_deposito_revision, `deposito_reparacion` = p_deposito_reparacion,

`diagnostico` = p_diagnostico, `estado_aparato` = p_estado_aparato, `repuestos` = p_repuestos, `mano_obra` = p_mano_obra,

`fecha_alta` = p_fecha_alta, `fecha_retiro` = p_fecha_retiro, `ubicacion` = p_ubicacion, `parcial_pagar` = p_parcial_pagar

WHERE `idorden` = p_idorden;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_parametro` (IN `p_idparametro` INT(11), IN `p_nombre_empresa` VARCHAR(150), IN `p_propietario` VARCHAR(150), IN `p_numero_nit` VARCHAR(70), IN `p_numero_nrc` VARCHAR(70), IN `p_porcentaje_iva` DECIMAL(13,2), IN `p_porcentaje_retencion` DECIMAL(13,2), IN `p_monto_retencion` DECIMAL(13,2), IN `p_direccion_empresa` VARCHAR(200), IN `p_idcurrency` INT(11))   BEGIN

UPDATE `parametro`

SET `nombre_empresa` = p_nombre_empresa, `propietario` = p_propietario, `numero_nit` = p_numero_nit, `numero_nrc` = p_numero_nrc,

`porcentaje_iva` = p_porcentaje_iva, `porcentaje_retencion` = p_porcentaje_retencion,

`monto_retencion` = p_monto_retencion,`direccion_empresa` = p_direccion_empresa,`idcurrency` = p_idcurrency

WHERE `idparametro` = p_idparametro;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_perecedero` (IN `p_fecha_vencimiento` DATE, IN `p_cantidad_perecedero` DECIMAL(13,2), IN `p_idproducto` INT(11))   BEGIN

  UPDATE `perecedero` SET

  `cantidad_perecedero` = p_cantidad_perecedero

   WHERE `idproducto` =  p_idproducto AND `fecha_vencimiento` = p_fecha_vencimiento;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_presentacion` (IN `p_idpresentacion` INT(11), IN `p_nombre_presentacion` VARCHAR(120), IN `p_siglas` VARCHAR(45), IN `p_estado` TINYINT(1))   BEGIN

UPDATE `presentacion`

SET `nombre_presentacion` = p_nombre_presentacion,

`siglas` = p_siglas,

`estado` = p_estado

WHERE `idpresentacion` = p_idpresentacion;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_producto` (IN `p_idproducto` INT(11), IN `p_codigo_barra` VARCHAR(200), IN `p_codigo_alternativo` VARCHAR(200), IN `p_nombre_producto` VARCHAR(175), IN `p_precio_compra` DECIMAL(13,2), IN `p_precio_venta` DECIMAL(13,2), IN `p_precio_venta1` DECIMAL(13,2), IN `p_precio_venta2` DECIMAL(13,2), IN `p_precio_venta3` DECIMAL(13,2), IN `p_precio_venta_mayoreo` DECIMAL(13,2), IN `p_stock_min` DECIMAL(13,2), IN `p_idcategoria` INT(11), IN `p_idmarca` INT(11), IN `p_idpresentacion` INT(11), IN `p_estado` TINYINT(1), IN `p_exento` TINYINT(1), IN `p_inventariable` TINYINT(1), IN `p_perecedero` TINYINT(1), IN `p_image` VARCHAR(170), IN `p_usuario` INT(11))   BEGIN

  IF (p_inventariable = 0) THEN

		UPDATE `producto`

		SET `codigo_barra` = p_codigo_barra, `codigo_alternativo` = p_codigo_alternativo, `nombre_producto` = p_nombre_producto, `precio_compra` = p_precio_compra,
		`precio_venta` = p_precio_venta, `precio_venta1` = p_precio_venta1, `precio_venta2` = p_precio_venta2, `precio_venta3` = p_precio_venta3,`precio_venta_mayoreo` = p_precio_venta_mayoreo,`stock_min` = 0, `stock` = 0, `idcategoria` = p_idcategoria, `idmarca` = p_idmarca, `idpresentacion` = p_idpresentacion, `estado` = p_estado, `exento` = p_exento, `inventariable` = p_inventariable, `perecedero` = p_perecedero, `imagen` = p_image, `usuario` = p_usuario

		WHERE `idproducto` = p_idproducto;

	ELSE

		UPDATE `producto`

		SET `codigo_barra` = p_codigo_barra, `codigo_alternativo` = p_codigo_alternativo, `nombre_producto` = p_nombre_producto, `precio_compra` = p_precio_compra,

		`precio_venta` = p_precio_venta, `precio_venta1` = p_precio_venta1, `precio_venta2` = p_precio_venta2, `precio_venta3` = p_precio_venta3, `precio_venta_mayoreo` = p_precio_venta_mayoreo,`stock_min` = p_stock_min, `idcategoria` = p_idcategoria, `idmarca` = p_idmarca, `idpresentacion` = p_idpresentacion, `estado` = p_estado, `exento` = p_exento, `inventariable` = p_inventariable, `perecedero` = p_perecedero, `imagen` = p_image, `usuario` = p_usuario

		WHERE `idproducto` = p_idproducto;

  END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_proveedor` (IN `p_idproveedor` INT(11), IN `p_nombre_proveedor` VARCHAR(175), IN `p_numero_telefono` VARCHAR(70), IN `p_numero_nit` VARCHAR(70), IN `p_numero_nrc` VARCHAR(70), IN `p_nombre_contacto` VARCHAR(150), IN `p_telefono_contacto` VARCHAR(150), IN `p_estado` TINYINT(1))   BEGIN

UPDATE `proveedor`

SET `nombre_proveedor` = p_nombre_proveedor, `numero_telefono` = p_numero_telefono, `numero_nit` = p_numero_nit,

`numero_nrc` = p_numero_nrc, `nombre_contacto` = p_nombre_contacto, `telefono_contacto` = p_telefono_contacto, `estado` = p_estado

WHERE `idproveedor` = p_idproveedor;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_tecnico` (IN `p_idtecnico` INT(11), IN `p_tecnico` VARCHAR(150), IN `p_telefono` VARCHAR(70), IN `p_estado` TINYINT(1))   BEGIN

	UPDATE `tecnico`

	SET `tecnico` = p_tecnico, `telefono` = p_telefono, `estado` = p_estado

	WHERE `idtecnico` = p_idtecnico;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_tiraje_comprobante` (IN `p_idtiraje` INT(11), IN `p_fecha_resolucion` DATETIME, IN `p_numero_resolucion` VARCHAR(100), IN `p_serie` VARCHAR(175), IN `p_desde` INT(11), IN `p_hasta` INT(11), IN `p_disponibles` INT(11), IN `p_idcomprobante` INT(11))   BEGIN

UPDATE `tiraje_comprobante`

SET `fecha_resolucion` = p_fecha_resolucion, `numero_resolucion` = p_numero_resolucion, `serie` = p_serie, `desde` = p_desde,

`hasta` = p_hasta, `disponibles` = p_disponibles, `idcomprobante` = p_idcomprobante

WHERE `idtiraje` = p_idtiraje;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_usuario` (IN `p_idusuario` INT(11), IN `p_usuario` VARCHAR(70), IN `p_contrasena` VARCHAR(180), IN `p_tipo_usuario` TINYINT(1), IN `p_estado` TINYINT(1), IN `p_idempleado` INT(11))   BEGIN

UPDATE `usuario`

SET `usuario` = p_usuario, `contrasena` = p_contrasena, `tipo_usuario` = p_tipo_usuario, `estado` = p_estado,

`idempleado` = p_idempleado

WHERE `idusuario` = p_idusuario;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_validar_caja` ()   BEGIN

		SELECT * FROM caja WHERE DATE(fecha_apertura) = CURDATE()

        AND estado = 1;

	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_validar_inventario` ()   BEGIN



	  DECLARE producto_count INT;

      DECLARE count_inventario INT;

	  SET producto_count = (SELECT COUNT(*) FROM producto);

      SET count_inventario = (SELECT COUNT(*) FROM inventario

      WHERE fecha_apertura = DATE_FORMAT(CURDATE(),'%Y-%m-01')

      AND fecha_cierre = LAST_DAY(CURDATE()) AND estado = 1);





      IF(producto_count != 0)THEN



			IF(count_inventario != 0) THEN



				SELECT "VALIDADO" as respuesta;



			ELSE



				SELECT "NO EXISTE" as respuesta;



            END IF;



        ELSE



		SELECT "SIN PRODUCTOS" as respuesta;



	 END IF;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ventas_anual` ()   BEGIN

	DECLARE count_venta INT;

    SET count_venta = (SELECT COUNT(*) FROM venta WHERE estado = 1);



	IF (count_venta > 0 ) THEN



	SELECT IF (UCASE(DATE_FORMAT(fecha_venta,'%b')) IS NULL,'0.00',

    UCASE(DATE_FORMAT(fecha_venta,'%b'))) as mes,

    IF(SUM(total) IS NULL, 0.00, SUM(total)) as total FROM venta

	WHERE YEAR(fecha_venta) = YEAR(CURDATE()) AND estado = 1 GROUP BY MONTH(fecha_venta);



    ELSE



    SELECT '-' as mes,'0.00' as total;





    END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_abonos` (IN `p_idcredito` INT(11))   BEGIN

	SELECT * FROM view_abonos WHERE idcredito = p_idcredito;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_all_abonos` ()   BEGIN

	SELECT * FROM view_abonos;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_apartado` (IN `p_idapartado` INT(11))   BEGIN



	SELECT numero_apartado,fecha_apartado,fecha_limite_retiro,cliente,

    sumas,iva,(sumas + iva) as subtotal,

    total_exento,retenido,total_descuento,total

    FROM view_apartados WHERE idapartado = p_idapartado

    GROUP BY numero_apartado;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_categoria` ()   BEGIN

SELECT `idcategoria`, `nombre_categoria`, `estado`

FROM `categoria`;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_categoria_activa` ()   BEGIN

SELECT `idcategoria`, `nombre_categoria`, `estado`

FROM `categoria` WHERE `estado` = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_cliente` ()   BEGIN

SELECT `idcliente`, `codigo_cliente`, `nombre_cliente`, `numero_nit`,

`numero_nrc`, `direccion_cliente`, `numero_telefono`, `email`,

`giro`, `limite_credito`, `estado`, `iddias`

FROM `cliente`;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_cliente_activo` ()   BEGIN

SELECT `idcliente`, `codigo_cliente`, `nombre_cliente`, `numero_nit`,
`numero_nrc`, `direccion_cliente`, `numero_telefono`, `email`, `giro`, `limite_credito`, `estado`, `iddias`
FROM `cliente` WHERE `estado` = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_cliente_inactivo` ()   BEGIN

SELECT `idcliente`, `codigo_cliente`, `nombre_cliente`, `numero_nit`,

`numero_nrc`, `direccion_cliente`, `numero_telefono`, `email`,

`giro`, `limite_credito`, `estado`, `iddias`

FROM `cliente` WHERE `estado` = 0;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_compra` (IN `p_idcompra` INT(11))   BEGIN



		SELECT fecha_compra,tipo_pago,nombre_proveedor,numero_nit,

		numero_comprobante,tipo_comprobante,fecha_comprobante,

        sumas,iva,(sumas + iva) as subtotal,

		total_exento,retenido,total

		FROM view_compras WHERE idcompra = p_idcompra

		GROUP BY fecha_compra,numero_comprobante;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_comprobante` ()   BEGIN

SELECT `idcomprobante`, `nombre_comprobante`, `estado`

FROM `comprobante`;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_comprobante_activo` ()   BEGIN

SELECT `idcomprobante`, `nombre_comprobante` FROM `comprobante` WHERE `estado` = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_cotizacion` (IN `p_fecha` DATE, IN `p_fecha2` DATE)   BEGIN

	  IF(p_fecha = '' AND p_fecha2 ='') THEN



			SELECT * FROM view_cotizaciones as vc
                        LEFT JOIN silverauto.venta as v 
                        ON vc.idVenta = v.idventa
                        WHERE V.facturado IS NULL
                        GROUP BY numero_cotizacion;



	   ELSE

			SELECT * FROM view_cotizaciones as vc
                        LEFT JOIN silverauto.venta as v
                        ON vc.idVenta = v.idventa
                        WHERE (fecha_cotizacion BETWEEN p_fecha AND p_fecha2)
                        AND V.facturado IS NULL
			GROUP BY numero_cotizacion;



	  END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_cotizacion_detalle` (`p_idcotizacion` INT)   BEGIN

	IF  p_idcotizacion  = '' THEN



		SET p_idcotizacion = (SELECT MAX(idcotizacion) FROM cotizacion);



		SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,disponible,

		nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,importe

		FROM view_cotizaciones WHERE idcotizacion = p_idcotizacion;



	ELSE



		SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,disponible,

		nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,importe

		FROM view_cotizaciones WHERE idcotizacion = p_idcotizacion;



    END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_creditos` (IN `p_criterio` TINYINT(1))   BEGIN

	SELECT * FROM view_creditos_venta WHERE estado_credito = p_criterio;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_creditos_espc` (IN `p_idcredito` INT)   BEGIN

	SELECT * FROM view_creditos_venta WHERE idcredito = p_idcredito;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_currency` ()   BEGIN

SELECT `idcurrency`, `CurrencyISO`, `Language`, `CurrencyName`, 

`Money`, `Symbol`

FROM `currency`;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_datos_caja` ()   BEGIN

   SELECT COUNT(*) as veces_abierta, fecha_apertura, fecha_cierre , estado, monto_apertura

   FROM caja WHERE DATE(fecha_apertura) = CURDATE();

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_ddl_cotizacion` (IN `p_idcotizacion` INT(11))   BEGIN

SELECT `a_nombre`, `numero_cotizacion`, `idcliente`

FROM cotizacion

WHERE idcotizacion = p_idcotizacion;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_detalleapartado` (IN `p_idapartado` INT(11))   BEGIN



	SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

	nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,importe,sumas,

	iva,total_exento,retenido,total_descuento,total,fecha_vence FROM

	view_apartados WHERE idapartado = p_idapartado;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_detallecompra` (IN `p_idcompra` INT(11))   BEGIN



		SELECT idproducto,codigo_barra,codigo_interno,fecha_vence,nombre_producto,

        nombre_marca,siglas,cantidad,precio_unitario,exento,importe,sumas,

        iva,total_exento,retenido,total FROM

        view_compras WHERE idcompra = p_idcompra;



	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_detalleventa` (IN `p_idventa` INT(11))   BEGIN



	SELECT idproducto,codigo_barra,codigo_interno,nombre_producto,

	nombre_marca,siglas,cantidad,precio_unitario,exento,descuento,importe,sumas,

	iva,total_exento,retenido,total_descuento,total,fecha_vence FROM

	view_ventas WHERE idventa = p_idventa;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_devoluciones_caja` ()   BEGIN

   SELECT * FROM view_caja WHERE tipo_movimiento = 2 AND DATE(fecha_apertura) = CURDATE();

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_dias` ()   BEGIN

SELECT `iddias`, `cantidad_dias`, `estado`

FROM `dias`;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_dias_activa` ()   BEGIN

SELECT `iddias`, `cantidad_dias`, `estado`

FROM `dias` WHERE `estado` = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_empleado` ()   BEGIN

SELECT `idempleado`, `codigo_empleado`, `nombre_empleado`, `apellido_empleado`,

`telefono_empleado`, `email_empleado`, `estado`, `imagen`

FROM `empleado`;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_empleado_activo` ()   BEGIN

SELECT `idempleado`, `codigo_empleado`, `nombre_empleado`, `apellido_empleado`,

`telefono_empleado`, `email_empleado`, `estado`, `imagen`

FROM `empleado` WHERE `estado` = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_entradas` (IN `p_mes` VARCHAR(7))   BEGIN

    IF (p_mes!='') THEN



		SELECT * FROM view_full_entradas WHERE DATE_FORMAT(fecha_entrada,'%Y-%m') = p_mes

		ORDER BY idproducto;



	ELSE



		SELECT * FROM view_full_entradas WHERE DATE_FORMAT(fecha_entrada,'%Y-%m') = DATE_FORMAT(CURDATE(),'%Y-%m')

		ORDER BY idproducto;



    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_gastos_caja` ()   BEGIN

   SELECT * FROM view_caja WHERE tipo_movimiento = 4 AND DATE(fecha_apertura) = CURDATE();

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_historial` ()  DETERMINISTIC BEGIN

SELECT num_historial, codigo_interno, codigo_barra, codigo_alternativo, nombre_producto, tipo_movimiento, stock_actual, stock_anterior, fecha_movimiento, usuario FROM view_historial;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_idproducto` (IN `p_idcotizacion` INT(11))   BEGIN

SELECT idproducto

FROM view_cotizaciones WHERE idcotizacion = p_idcotizacion;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_idproducto_historial` (IN `p_idproducto` INT)   BEGIN

SELECT *

FROM view_historial WHERE idproducto = p_idproducto;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_impuesto` ()   BEGIN

SELECT `porcentaje_iva`,`porcentaje_retencion`,`monto_retencion`  FROM `parametro`;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_info_cotizacion` (IN `p_idcotizacion` INT(11))   BEGIN



    IF  p_idcotizacion  = '' THEN



        SET p_idcotizacion = (SELECT MAX(idcotizacion) FROM cotizacion);



        SELECT numero_cotizacion, fecha_cotizacion, a_nombre, numero_nit,

        direccion_cliente, numero_telefono, email, tipo_pago, entrega, a_nombre as nombre_cliente, cantidad, precio_unitario, importe, nombre_producto,

        sumas, iva, sumas as subtotal,

        total_exento, exento, retenido, total_descuento, descuento, total, empleado

        FROM view_cotizaciones WHERE idcotizacion = p_idcotizacion

        GROUP BY numero_cotizacion;



    ELSE



        SELECT numero_cotizacion,fecha_cotizacion,a_nombre,numero_nit,

        direccion_cliente,numero_telefono,email,tipo_pago,entrega, a_nombre as nombre_cliente, cantidad, precio_unitario, importe, nombre_producto,

        sumas,iva,sumas as subtotal,

        total_exento,exento,retenido,descuento,total,empleado

        FROM view_cotizaciones WHERE idcotizacion = p_idcotizacion

        GROUP BY numero_cotizacion;



    END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_ingresos_caja` ()   BEGIN

   SELECT * FROM view_caja WHERE tipo_movimiento = 1 AND DATE(fecha_apertura) = CURDATE();

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_limite_credito` (IN `p_idcliente` INT(11))   BEGIN



  SELECT limite_credito FROM cliente

  WHERE idcliente = p_idcliente LIMIT 1;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_marca` ()   BEGIN

SELECT `idmarca`, `nombre_marca`, `estado`

FROM `marca`;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_marca_activa` ()   BEGIN

SELECT `idmarca`, `nombre_marca`, `estado`

FROM `marca` WHERE `estado` = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_money` ()   BEGIN

DECLARE p_idcurrency INT;

SET p_idcurrency = (SELECT MAX(idcurrency) FROM parametro);

SELECT `CurrencyISO`,`Symbol`,`CurrencyName`

FROM `currency`

WHERE `idcurrency` = p_idcurrency;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_monto_credito` (IN `p_idcredito` INT(11))   BEGIN

	SELECT monto_restante FROM credito WHERE idcredito = p_idcredito;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_movimientos_caja` ()   BEGIN



   DECLARE p_ingresos DECIMAL(13,2);

   DECLARE p_ingresos_totales DECIMAL(13,2);

   DECLARE p_devoluciones DECIMAL(13,2);

   DECLARE p_prestamos DECIMAL(13,2);

   DECLARE p_gastos DECIMAL(13,2);

   DECLARE p_egresos DECIMAL(13,2);

   DECLARE p_saldo DECIMAL(13,2);

   DECLARE p_diferencia DECIMAL(13,2);

   DECLARE p_total_movimiento DECIMAL(13,2);

   DECLARE p_monto_inicial DECIMAL(13,2);



   DECLARE c_ingresos int;

   DECLARE c_devoluciones int;

   DECLARE c_prestamos int;

   DECLARE c_gastos int;





   SET p_ingresos = (SELECT SUM(monto_movimiento) FROM view_caja WHERE

   DATE(fecha_apertura) = CURDATE() AND tipo_movimiento = 1);



   SET p_devoluciones = (SELECT SUM(monto_movimiento) FROM view_caja WHERE

   DATE(fecha_apertura) = CURDATE() AND tipo_movimiento = 2);



   SET p_prestamos = (SELECT SUM(monto_movimiento) FROM view_caja WHERE

   DATE(fecha_apertura) = CURDATE() AND tipo_movimiento = 3);



   SET p_gastos = (SELECT SUM(monto_movimiento) FROM view_caja WHERE

   DATE(fecha_apertura) = CURDATE() AND tipo_movimiento = 4);



   SET p_monto_inicial = (SELECT monto_apertura FROM caja WHERE DATE(fecha_apertura) = CURDATE());





   SET c_ingresos = (SELECT COUNT(*) FROM view_caja WHERE

   DATE(fecha_apertura) = CURDATE() AND tipo_movimiento = 1);



   SET c_devoluciones = (SELECT COUNT(*) FROM view_caja WHERE

   DATE(fecha_apertura) = CURDATE() AND tipo_movimiento = 2);



   SET c_prestamos = (SELECT COUNT(*) FROM view_caja WHERE

   DATE(fecha_apertura) = CURDATE() AND tipo_movimiento = 3);



   SET c_gastos = (SELECT COUNT(*) FROM view_caja WHERE

   DATE(fecha_apertura) = CURDATE() AND tipo_movimiento = 4);



   IF (p_ingresos IS NULL) THEN

		SET p_ingresos = (0.00);

   END IF;



   IF (p_devoluciones IS NULL) THEN

      SET p_devoluciones = (0.00);

   END IF;



   IF (p_gastos IS NULL) THEN

     SET p_gastos = (0.00);

   END IF;



   IF (p_prestamos IS NULL) THEN

     SET p_prestamos = (0.00);

   END IF;



   SET p_egresos = (p_prestamos + p_gastos);

   SET p_ingresos_totales = (p_ingresos +  p_devoluciones);

   SET p_saldo = (p_ingresos - p_egresos +  p_devoluciones);

   SET p_total_movimiento = (p_ingresos + p_egresos);

   SET p_diferencia = (p_monto_inicial + p_saldo);



   SELECT p_ingresos, p_devoluciones , p_prestamos , p_gastos, p_egresos, p_saldo, p_total_movimiento,

   c_ingresos, c_devoluciones , c_prestamos , c_gastos, p_monto_inicial, p_diferencia, p_ingresos_totales;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_ordentaller` (IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10))   BEGIN



 IF (p_date = '' AND p_date2 = '') THEN

		SELECT * FROM view_taller ORDER BY fecha_ingreso DESC;

	ELSE

		 SELECT * FROM view_taller WHERE DATE_FORMAT(fecha_ingreso,'%Y-%m-%d') BETWEEN p_date AND p_date2

		 ORDER BY  DATE_FORMAT(fecha_ingreso,'%Y-%m-%d') DESC;

    END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_parametro` ()   BEGIN

SELECT `idparametro`, `nombre_empresa`, `propietario`, `numero_nit`,

`numero_nrc`, `porcentaje_iva`, `porcentaje_retencion`, `monto_retencion`,

`direccion_empresa`, `logo_empresa`, `idcurrency`

FROM `parametro`;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_perecedero` (IN `p_desde` DATE, IN `p_hasta` DATE)   BEGIN

	IF p_desde IS NULL AND p_hasta IS NULL THEN

		SELECT * FROM view_perecederos;

	ELSE

		SELECT * FROM view_perecederos WHERE fecha_vencimiento

		BETWEEN p_desde AND p_hasta;

	END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_presentacion` ()   BEGIN

SELECT `idpresentacion`, `nombre_presentacion`, `siglas` , `estado`

FROM `presentacion`;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_presentacion_activa` ()   BEGIN

SELECT `idpresentacion`, `nombre_presentacion`, `siglas` , `estado`

FROM `presentacion` WHERE `estado` = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_prestamos_caja` ()   BEGIN

   SELECT * FROM view_caja WHERE tipo_movimiento = 3 AND DATE(fecha_apertura) = CURDATE();

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_producto` ()   BEGIN

SELECT * FROM view_productos;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_productoXid` (IN `p_idproducto` INT)   SELECT * FROM `view_productos` WHERE idproducto = p_idproducto$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_producto_activo` ()   BEGIN

SELECT * FROM view_productos WHERE estado = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_producto_agotado` ()   BEGIN

SELECT * FROM view_productos WHERE stock = 0;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_producto_inactivo` ()   BEGIN

SELECT * FROM view_productos WHERE estado = 0;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_producto_no_perecedero` ()   BEGIN

SELECT * FROM view_productos WHERE estado = 1 AND perecedero = 0 AND  stock > 0.00 AND inventariable = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_producto_perecedero` ()   BEGIN

SELECT * FROM view_productos WHERE estado = 1 AND perecedero = 1 AND  stock > 0.00 AND inventariable = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_producto_vigente` ()   BEGIN

SELECT * FROM view_productos WHERE estado = 1 AND stock > 0.00;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_proveedor` ()   BEGIN

SELECT `idproveedor`, `codigo_proveedor`, `nombre_proveedor`, `numero_telefono`,

`numero_nit`, `numero_nrc`, `nombre_contacto`, `telefono_contacto`,

`estado`

FROM `proveedor`;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_proveedor_activo` ()   BEGIN

SELECT `idproveedor`, `codigo_proveedor`, `nombre_proveedor`, `numero_telefono`,

`numero_nit`, `numero_nrc`, `nombre_contacto`, `telefono_contacto`,

`estado`

FROM `proveedor` WHERE `estado`= 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_report_ordentaller` (IN `p_id` INT)   BEGIN

	DECLARE p_idmax int;

	 IF (p_id  = '0') THEN

		SET p_idmax = (SELECT MAX(idorden) FROM ordentaller);

		SELECT * FROM view_taller WHERE idorden = p_idmax;

	 ELSE

		 SELECT * FROM view_taller WHERE idorden = p_id;

	 END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_salidas` (IN `p_mes` VARCHAR(7))   BEGIN

    IF (p_mes!='') THEN



		SELECT * FROM view_full_salidas WHERE DATE_FORMAT(fecha_salida,'%Y-%m') = p_mes

		ORDER BY idproducto;



	ELSE



		SELECT * FROM view_full_salidas WHERE DATE_FORMAT(fecha_salida,'%Y-%m') = DATE_FORMAT(CURDATE(),'%Y-%m')

		ORDER BY idproducto;



    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_stock_producto_perecedero` (IN `p_idproducto` INT(11))   BEGIN

SELECT stock FROM view_productos WHERE estado = 1 AND perecedero = 1

AND  stock > 0.00 AND inventariable = 1 AND idproducto = p_idproducto ;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_tecnico` ()   BEGIN

	SELECT `idtecnico`, `tecnico`, `telefono`, `estado`

	FROM `tecnico`;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_tecnico_activo` ()   BEGIN

	SELECT `idtecnico`, `tecnico`, `telefono`, `estado`

	FROM `tecnico` WHERE `estado` = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_tiraje` ()   BEGIN

SELECT * FROM view_comprobantes;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_tiraje_activo` ()   BEGIN

SELECT idcomprobante, nombre_comprobante FROM view_comprobantes WHERE estado = 1 AND

disponibles > 0;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_total_abonos_fechas` (IN `p_date` VARCHAR(10), IN `p_date2` VARCHAR(10))   BEGIN

		 SELECT codigo_credito, nombre_credito, monto_abono, DATE_FORMAT(fecha_abono,'%d/%m/%Y') as fecha_abono

         FROM view_abonos WHERE DATE_FORMAT(fecha_abono,'%Y-%m-%d') BETWEEN p_date AND p_date2

		 ORDER BY monto_abono, DATE_FORMAT(fecha_abono,'%d/%m/%Y')  DESC;

	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_usuario` ()   BEGIN

SELECT * FROM view_usuarios;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_view_venta` (IN `p_idventa` INT(11))   BEGIN



	SELECT numero_venta,fecha_venta,tipo_pago,cliente,

    pago_efectivo,pago_tarjeta,numero_tarjeta,tarjeta_habiente,cambio,

    numero_comprobante,tipo_comprobante,sumas,iva,(sumas + iva) as subtotal,

    total_exento,retenido,total_descuento,total

    FROM view_ventas WHERE idventa = p_idventa

    GROUP BY numero_venta;



END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `abono`
--

CREATE TABLE `abono` (
  `idabono` int(11) NOT NULL,
  `idcredito` int(11) NOT NULL,
  `fecha_abono` datetime NOT NULL,
  `monto_abono` decimal(13,2) NOT NULL,
  `total_abonado` decimal(13,2) DEFAULT 0.00,
  `restante_credito` decimal(13,2) NOT NULL DEFAULT 0.00,
  `idusuario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `apartado`
--

CREATE TABLE `apartado` (
  `idapartado` int(11) NOT NULL,
  `numero_apartado` varchar(175) DEFAULT NULL,
  `fecha_apartado` datetime NOT NULL,
  `fecha_limite_retiro` datetime NOT NULL,
  `sumas` decimal(13,2) NOT NULL,
  `iva` decimal(13,2) NOT NULL,
  `exento` decimal(13,2) NOT NULL,
  `retenido` decimal(13,2) NOT NULL,
  `descuento` decimal(13,2) NOT NULL,
  `total` decimal(13,2) NOT NULL,
  `abonado_apartado` decimal(13,2) NOT NULL DEFAULT 0.00,
  `restante_pagar` decimal(13,2) NOT NULL DEFAULT 0.00,
  `sonletras` varchar(150) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1,
  `idcliente` int(11) DEFAULT NULL,
  `idusuario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `apartado`
--
DELIMITER $$
CREATE TRIGGER `generar_numero_apartado` BEFORE INSERT ON `apartado` FOR EACH ROW BEGIN

    

        DECLARE numero INT(11);



        SET numero = (SELECT max(idapartado) FROM apartado);

        

		IF numero IS NULL then

		  set numero=1;

        SET NEW.numero_apartado='APR00000001';



		ELSEIF numero >= 1 and numero < 9 then

			set numero=numero+1;

		SET NEW.numero_apartado=(select concat('APR0000000',CAST(numero AS CHAR)));

        

		ELSEIF numero >=9 and numero<=99 then

			set numero=numero+1;

		SET NEW.numero_apartado=(select concat('APR000000',CAST(numero AS CHAR)));

            

		ELSEIF numero>=99 and numero<=999 then

			set numero=numero+1;

		SET NEW.numero_apartado=(select concat('APR00000',CAST(numero AS CHAR)));

             

		ELSEIF numero>=999 and numero<=9999 then

		   set numero=numero+1;

		SET NEW.numero_apartado=(select concat('APR0000',CAST(numero AS CHAR)));

           

		ELSEIF numero>=9999 and numero<=99999 then

			set numero=numero+1;

		SET NEW.numero_apartado=(select concat('APR000',CAST(numero AS CHAR)));

             

		ELSEIF numero>=99999 and numero<=999999 then

			set numero=numero+1;

		SET NEW.numero_apartado=(select concat('APR00',CAST(numero AS CHAR)));

            

		ELSEIF numero>=999999 and numero<=9999999 then

			set numero=numero+1;

		SET NEW.numero_apartado=(select concat('APR0',CAST(numero AS CHAR)));

            

        ELSEIF numero>=9999999  then 			set numero=numero+1;

		SET NEW.numero_apartado=(select concat('APR',CAST(numero AS CHAR)));

            

		END IF;

    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `caja`
--

CREATE TABLE `caja` (
  `idcaja` int(11) NOT NULL,
  `fecha_apertura` datetime NOT NULL,
  `monto_apertura` decimal(13,2) NOT NULL,
  `monto_cierre` decimal(13,2) DEFAULT 0.00,
  `fecha_cierre` datetime DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `caja`
--

INSERT INTO `caja` (`idcaja`, `fecha_apertura`, `monto_apertura`, `monto_cierre`, `fecha_cierre`, `estado`) VALUES
(1, '2024-07-04 10:52:17', 1000.00, 0.00, NULL, 1),
(2, '2024-07-05 09:02:27', 1000.00, 0.00, NULL, 1),
(3, '2024-07-06 12:23:54', 100.00, 0.00, NULL, 1),
(4, '2024-07-07 00:01:00', 1000.00, 0.00, NULL, 1),
(5, '2024-07-08 09:51:45', 1000.00, 0.00, NULL, 1),
(6, '2024-07-15 14:23:35', 1000.00, 0.00, NULL, 1),
(7, '2024-07-16 09:28:41', 100.00, 0.00, NULL, 1),
(8, '2024-07-17 15:39:09', 100.00, 0.00, NULL, 1),
(9, '2024-07-22 11:59:28', 100.00, 0.00, NULL, 1),
(10, '2024-07-24 08:59:10', 100.00, 0.00, NULL, 1),
(11, '2024-07-25 12:59:49', 100.00, 0.00, NULL, 1),
(12, '2024-07-26 15:13:44', 100.00, 0.00, NULL, 1),
(13, '2024-07-31 14:50:19', 100.00, 0.00, NULL, 1),
(14, '2024-10-14 09:33:00', 1000.00, 0.00, NULL, 1),
(15, '2024-10-15 08:22:58', 1000.00, 0.00, NULL, 1),
(16, '2024-10-17 08:14:57', 1000.00, 0.00, NULL, 1),
(17, '2024-10-18 08:38:26', 1000.00, 0.00, NULL, 1),
(18, '2024-10-21 09:33:07', 1000.00, 0.00, NULL, 1),
(19, '2024-10-22 11:38:39', 1000.00, 0.00, NULL, 1),
(20, '2024-10-24 12:36:09', 1000.00, 0.00, NULL, 1),
(21, '2024-10-28 09:36:23', 1000.00, 0.00, NULL, 1),
(22, '2024-10-29 12:17:47', 1000.00, 0.00, NULL, 1),
(23, '2024-10-30 08:12:28', 1000.00, 0.00, NULL, 1),
(24, '2024-10-31 09:07:01', 1000.00, 0.00, NULL, 1),
(25, '2024-11-01 09:26:59', 1000.00, 0.00, NULL, 1),
(26, '2024-11-06 15:14:05', 1000.00, 0.00, NULL, 1),
(27, '2024-11-08 08:18:25', 1000.00, 0.00, NULL, 1),
(28, '2024-11-12 09:51:06', 1000.00, 0.00, NULL, 1),
(29, '2024-11-13 08:48:52', 1000.00, 0.00, NULL, 1),
(30, '2024-11-15 12:01:02', 1000.00, 0.00, NULL, 1),
(31, '2024-11-16 20:20:19', 1000.00, 0.00, NULL, 1),
(32, '2024-11-19 09:26:14', 1000.00, 0.00, NULL, 1),
(33, '2024-11-20 08:41:28', 1000.00, 0.00, NULL, 1),
(34, '2024-12-10 12:47:57', 1000.00, 0.00, NULL, 1),
(35, '2024-12-28 06:23:20', 30.00, 0.00, NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `caja_movimiento`
--

CREATE TABLE `caja_movimiento` (
  `idcaja` int(11) NOT NULL,
  `tipo_movimiento` tinyint(1) NOT NULL DEFAULT 0,
  `monto_movimiento` decimal(13,2) NOT NULL,
  `descripcion_movimiento` varchar(80) DEFAULT NULL,
  `fecha_movimiento` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `caja_movimiento`
--

INSERT INTO `caja_movimiento` (`idcaja`, `tipo_movimiento`, `monto_movimiento`, `descripcion_movimiento`, `fecha_movimiento`) VALUES
(1, 1, 40.00, 'POR VENTA FACTURA # 1', '2024-07-04'),
(1, 1, 42.80, 'POR VENTA TICKET # 1', '2024-07-04'),
(1, 1, 32.10, 'POR VENTA FACTURA # 2', '2024-07-04'),
(3, 1, 42.80, 'POR VENTA TICKET # 2', '2024-07-06'),
(3, 1, 30.00, 'POR VENTA TICKET # 3', '2024-07-06'),
(3, 1, 60.00, 'POR VENTA TICKET # 4', '2024-07-06'),
(3, 1, 90.00, 'POR VENTA TICKET # 5', '2024-07-06'),
(3, 1, 60.00, 'POR VENTA TICKET # 6', '2024-07-06'),
(4, 1, 128.40, 'POR VENTA TICKET # 7', '2024-07-07'),
(5, 1, 30.00, 'POR VENTA TICKET # 8', '2024-07-08'),
(5, 1, 42.80, 'POR VENTA TICKET # 9', '2024-07-08'),
(5, 1, 60.00, 'POR VENTA TICKET # 10', '2024-07-08'),
(5, 1, 90.00, 'POR VENTA TICKET # 11', '2024-07-08'),
(7, 1, 42.80, 'POR VENTA TICKET # 12', '2024-07-16'),
(7, 1, 72.80, 'POR VENTA TICKET # 13', '2024-07-16'),
(7, 1, 70.70, 'POR VENTA TICKET # 14', '2024-07-16'),
(9, 1, 150.00, 'POR VENTA TICKET # 15', '2024-07-22'),
(10, 1, 42.80, 'POR VENTA TICKET # 16', '2024-07-24'),
(10, 1, 60.00, 'POR VENTA TICKET # 17', '2024-07-24'),
(10, 1, 85.60, 'POR VENTA TICKET # 18', '2024-07-24'),
(11, 1, 42.80, 'POR VENTA TICKET # 23', '2024-07-25'),
(11, 1, 30.00, 'POR VENTA TICKET # 24', '2024-07-25'),
(11, 1, 85.60, 'POR VENTA TICKET # 25', '2024-07-25'),
(11, 1, 42.80, 'POR VENTA TICKET # 26', '2024-07-25');

-- --------------------------------------------------------

--
-- Table structure for table `categoria`
--

CREATE TABLE `categoria` (
  `idcategoria` int(11) NOT NULL,
  `nombre_categoria` varchar(120) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categoria`
--

INSERT INTO `categoria` (`idcategoria`, `nombre_categoria`, `estado`) VALUES
(1, 'TECNOLOGIA', 1),
(2, 'HOGAR', 1),
(3, 'HERRAMIENTA', 1),
(4, 'ORGANIZACION', 1);

-- --------------------------------------------------------

--
-- Table structure for table `cliente`
--

CREATE TABLE `cliente` (
  `idcliente` int(11) NOT NULL,
  `codigo_cliente` varchar(175) DEFAULT NULL,
  `nombre_cliente` varchar(150) NOT NULL,
  `numero_nit` varchar(70) DEFAULT NULL,
  `numero_nrc` varchar(70) DEFAULT NULL,
  `direccion_cliente` varchar(100) DEFAULT NULL,
  `numero_telefono` varchar(70) DEFAULT NULL,
  `email` varchar(80) DEFAULT NULL,
  `giro` varchar(80) DEFAULT NULL,
  `limite_credito` decimal(13,2) NOT NULL DEFAULT 0.00,
  `estado` tinyint(1) NOT NULL DEFAULT 1,
  `iddias` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cliente`
--

INSERT INTO `cliente` (`idcliente`, `codigo_cliente`, `nombre_cliente`, `numero_nit`, `numero_nrc`, `direccion_cliente`, `numero_telefono`, `email`, `giro`, `limite_credito`, `estado`, `iddias`) VALUES
(1, 'CL00000001', 'TOMAS CASTRO', '1', '1', '', '1', 'tommiguel93@gmail.com', '', 50.00, 1, 4);

--
-- Triggers `cliente`
--
DELIMITER $$
CREATE TRIGGER `generar_codigo_cliente` BEFORE INSERT ON `cliente` FOR EACH ROW BEGIN

    

        DECLARE numero INT;



        SET numero = (SELECT max(idcliente) FROM cliente);

        

		IF numero IS NULL then

		  set numero=1;

        SET NEW.codigo_cliente='CL00000001';



		ELSEIF numero >= 1 and numero < 9 then

			set numero=numero+1;

		SET NEW.codigo_cliente=(select concat('CL0000000',CAST(numero AS CHAR)));

        

		ELSEIF numero >=9 and numero<=99 then

			set numero=numero+1;

		SET NEW.codigo_cliente=(select concat('CL000000',CAST(numero AS CHAR)));

            

		ELSEIF numero>=99 and numero<=999 then

			set numero=numero+1;

		SET NEW.codigo_cliente=(select concat('CL00000',CAST(numero AS CHAR)));

             

		ELSEIF numero>=999 and numero<=9999 then

		   set numero=numero+1;

		SET NEW.codigo_cliente=(select concat('CL0000',CAST(numero AS CHAR)));

           

		ELSEIF numero>=9999 and numero<=99999 then

			set numero=numero+1;

		SET NEW.codigo_cliente=(select concat('CL000',CAST(numero AS CHAR)));

             

		ELSEIF numero>=99999 and numero<=999999 then

			set numero=numero+1;

		SET NEW.codigo_cliente=(select concat('CL00',CAST(numero AS CHAR)));

            

		ELSEIF numero>=999999 and numero<=9999999 then

			set numero=numero+1;

		SET NEW.codigo_cliente=(select concat('CL0',CAST(numero AS CHAR)));

            

        ELSEIF numero>=9999999  then 			set numero=numero+1;

		SET NEW.codigo_cliente=(select concat('CL',CAST(numero AS CHAR)));

            

		END IF;

    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `compra`
--

CREATE TABLE `compra` (
  `idcompra` int(11) NOT NULL,
  `fecha_compra` datetime NOT NULL,
  `idproveedor` int(11) NOT NULL,
  `tipo_pago` varchar(75) NOT NULL,
  `numero_comprobante` varchar(60) NOT NULL,
  `tipo_comprobante` varchar(60) NOT NULL,
  `fecha_comprobante` date DEFAULT NULL,
  `sumas` decimal(13,2) NOT NULL,
  `iva` decimal(13,2) NOT NULL,
  `exento` decimal(13,2) NOT NULL,
  `retenido` decimal(13,2) NOT NULL,
  `total` decimal(13,2) NOT NULL,
  `sonletras` varchar(150) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `compra`
--

INSERT INTO `compra` (`idcompra`, `fecha_compra`, `idproveedor`, `tipo_pago`, `numero_comprobante`, `tipo_comprobante`, `fecha_comprobante`, `sumas`, `iva`, `exento`, `retenido`, `total`, `sonletras`, `estado`) VALUES
(1, '2024-07-04 10:51:42', 1, '1', '1', '1', '2024-07-04', 200.00, 14.00, 0.00, 0.00, 214.00, 'DOSCIENTOS CATORCE 00/100 USD', 1),
(2, '2024-07-05 14:08:28', 1, '1', '2', '1', '2024-07-05', 0.00, 0.00, 20.00, 0.00, 20.00, 'CIENTOS VEINTE 00/100 USD', 1),
(3, '2024-11-01 11:00:04', 1, '1', '1', '1', '2024-11-01', 999.80, 69.99, 0.00, 0.00, 1069.79, 'MIL SESENTA Y NUEVE 79/100 USD', 1);

-- --------------------------------------------------------

--
-- Table structure for table `comprobante`
--

CREATE TABLE `comprobante` (
  `idcomprobante` int(11) NOT NULL,
  `nombre_comprobante` varchar(75) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `comprobante`
--

INSERT INTO `comprobante` (`idcomprobante`, `nombre_comprobante`, `estado`) VALUES
(1, 'TICKET', 1),
(2, 'FACTURA', 1),
(3, 'BOLETA', 1);

-- --------------------------------------------------------

--
-- Table structure for table `cotizacion`
--

CREATE TABLE `cotizacion` (
  `idcotizacion` int(11) NOT NULL,
  `numero_cotizacion` varchar(175) DEFAULT NULL,
  `fecha_cotizacion` datetime NOT NULL,
  `a_nombre` varchar(175) DEFAULT NULL,
  `tipo_pago` varchar(60) NOT NULL,
  `entrega` varchar(60) NOT NULL,
  `sumas` decimal(13,2) NOT NULL,
  `iva` decimal(13,2) NOT NULL,
  `exento` decimal(13,2) NOT NULL,
  `retenido` decimal(13,2) NOT NULL,
  `descuento` decimal(13,2) NOT NULL,
  `total` decimal(13,2) NOT NULL,
  `sonletras` varchar(150) NOT NULL,
  `idusuario` int(11) NOT NULL,
  `idcliente` int(11) NOT NULL,
  `idVenta` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `cotizacion`
--

INSERT INTO `cotizacion` (`idcotizacion`, `numero_cotizacion`, `fecha_cotizacion`, `a_nombre`, `tipo_pago`, `entrega`, `sumas`, `iva`, `exento`, `retenido`, `descuento`, `total`, `sonletras`, `idusuario`, `idcliente`, `idVenta`) VALUES
(1, 'COTI00000001', '2024-07-15 19:41:34', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 2, 1, NULL),
(2, 'COTI00000002', '2024-07-16 10:59:23', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 1, 1, 16),
(3, 'COTI00000003', '2024-07-25 11:55:10', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 80.00, 5.60, 0.00, 0.00, 0.00, 85.60, 'Cientos ochenta y cinco 60/100 USD', 1, 1, NULL),
(4, 'COTI00000004', '2024-07-25 20:25:27', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 1, 1, 42),
(5, 'COTI00000005', '2024-10-14 12:02:56', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 1, 1, NULL),
(6, 'COTI00000006', '2024-10-14 12:46:16', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 1, 1, NULL),
(7, 'COTI00000007', '2024-12-10 12:47:32', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 129.80, 4.19, 4.89, 0.00, 0.20, 133.99, 'Ciento treinta y tres 99/100 USD', 1, 1, NULL),
(8, 'COTI00000008', '2024-12-10 12:48:37', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 64.90, 2.10, 2.45, 0.00, 0.10, 67.00, 'Cientos sesenta y siete 00/100 USD', 1, 1, NULL),
(9, 'COTI00000009', '2024-12-12 11:37:47', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 1, 1, NULL),
(10, 'COTI00000010', '2024-12-12 11:51:02', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 1, 1, NULL),
(11, 'COTI00000011', '2024-12-12 12:38:32', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 1, 1, NULL),
(12, 'COTI00000012', '2024-12-12 14:30:29', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 1, 1, NULL),
(13, 'COTI00000013', '2024-12-12 14:32:34', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 1, 1, NULL),
(14, 'COTI00000014', '2024-12-12 14:47:33', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 1, 1, NULL),
(15, 'COTI00000015', '2024-12-12 14:52:32', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 1, 1, NULL),
(16, 'COTI00000016', '2024-12-12 14:55:21', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 1, 1, NULL),
(17, 'COTI00000017', '2024-12-12 15:36:50', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 130.00, 4.20, 4.90, 0.00, 0.00, 134.20, 'Ciento treinta y cuatro 20/100 USD', 1, 1, NULL),
(18, 'COTI00000018', '2024-12-13 08:13:38', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 70.00, 2.80, 2.10, 0.00, 0.00, 72.80, 'Cientos setenta y dos 80/100 USD', 1, 1, NULL),
(19, 'COTI00000019', '2024-12-13 08:47:28', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 70.00, 2.80, 2.10, 0.00, 0.00, 72.80, 'Cientos setenta y dos 80/100 USD', 1, 1, NULL),
(20, 'COTI00000020', '2024-12-13 12:42:27', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 1, 1, NULL),
(21, 'COTI00000021', '2024-12-17 12:04:33', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 1, 1, NULL),
(22, 'COTI00000022', '2024-12-17 12:27:12', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 1, 1, NULL),
(23, 'COTI00000023', '2024-12-17 12:28:17', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 70.00, 2.80, 2.10, 0.00, 0.00, 72.80, 'Cientos setenta y dos 80/100 USD', 1, 1, NULL),
(24, 'COTI00000024', '2024-12-28 06:21:51', 'TOMAS CASTRO', 'AL CONTADO', 'INMEDIATA', 48.32, 0.00, 2.10, 0.00, 0.00, 48.32, 'Cientos cuarenta y ocho 32/100 USD', 1, 1, NULL);

--
-- Triggers `cotizacion`
--
DELIMITER $$
CREATE TRIGGER `generar_numero_cotizacion` BEFORE INSERT ON `cotizacion` FOR EACH ROW BEGIN

    

        DECLARE numero INT(11);



        SET numero = (SELECT max(idcotizacion) FROM cotizacion);

        

		IF numero IS NULL then

		  set numero=1;

        SET NEW.numero_cotizacion='COTI00000001';



		ELSEIF numero >= 1 and numero < 9 then

			set numero=numero+1;

		SET NEW.numero_cotizacion=(select concat('COTI0000000',CAST(numero AS CHAR)));

        

		ELSEIF numero >=9 and numero<=99 then

			set numero=numero+1;

		SET NEW.numero_cotizacion=(select concat('COTI000000',CAST(numero AS CHAR)));

            

		ELSEIF numero>=99 and numero<=999 then

			set numero=numero+1;

		SET NEW.numero_cotizacion=(select concat('COTI00000',CAST(numero AS CHAR)));

             

		ELSEIF numero>=999 and numero<=9999 then

		   set numero=numero+1;

		SET NEW.numero_cotizacion=(select concat('COTI0000',CAST(numero AS CHAR)));

           

		ELSEIF numero>=9999 and numero<=99999 then

			set numero=numero+1;

		SET NEW.numero_cotizacion=(select concat('COTI000',CAST(numero AS CHAR)));

             

		ELSEIF numero>=99999 and numero<=999999 then

			set numero=numero+1;

		SET NEW.numero_cotizacion=(select concat('COTI00',CAST(numero AS CHAR)));

            

		ELSEIF numero>=999999 and numero<=9999999 then

			set numero=numero+1;

		SET NEW.numero_cotizacion=(select concat('COTI0',CAST(numero AS CHAR)));

            

        ELSEIF numero>=9999999  then 			set numero=numero+1;

		SET NEW.numero_cotizacion=(select concat('COTI',CAST(numero AS CHAR)));

            

		END IF;

    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `credito`
--

CREATE TABLE `credito` (
  `idcredito` int(11) NOT NULL,
  `idventa` int(11) DEFAULT NULL,
  `codigo_credito` varchar(175) DEFAULT NULL,
  `nombre_credito` varchar(120) NOT NULL,
  `fecha_credito` datetime NOT NULL,
  `monto_credito` decimal(13,2) NOT NULL,
  `monto_abonado` decimal(13,2) NOT NULL DEFAULT 0.00,
  `monto_restante` decimal(13,2) NOT NULL DEFAULT 0.00,
  `estado` tinyint(1) NOT NULL DEFAULT 0,
  `idcliente` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `credito`
--
DELIMITER $$
CREATE TRIGGER `generar_numero_credito` BEFORE INSERT ON `credito` FOR EACH ROW BEGIN

    

        DECLARE numero INT(11);



        SET numero = (SELECT max(idcredito) FROM credito);

        

		IF numero IS NULL then

		  set numero=1;

        SET NEW.codigo_credito='CRED00000001';



		ELSEIF numero >= 1 and numero < 9 then

			set numero=numero+1;

		SET NEW.codigo_credito=(select concat('CRED0000000',CAST(numero AS CHAR)));

        

		ELSEIF numero >=9 and numero<=99 then

			set numero=numero+1;

		SET NEW.codigo_credito=(select concat('CRED000000',CAST(numero AS CHAR)));

            

		ELSEIF numero>=99 and numero<=999 then

			set numero=numero+1;

		SET NEW.codigo_credito=(select concat('CRED00000',CAST(numero AS CHAR)));

             

		ELSEIF numero>=999 and numero<=9999 then

		   set numero=numero+1;

		SET NEW.codigo_credito=(select concat('CRED0000',CAST(numero AS CHAR)));

           

		ELSEIF numero>=9999 and numero<=99999 then

			set numero=numero+1;

		SET NEW.codigo_credito=(select concat('CRED000',CAST(numero AS CHAR)));

             

		ELSEIF numero>=99999 and numero<=999999 then

			set numero=numero+1;

		SET NEW.codigo_credito=(select concat('CRED00',CAST(numero AS CHAR)));

            

		ELSEIF numero>=999999 and numero<=9999999 then

			set numero=numero+1;

		SET NEW.codigo_credito=(select concat('CRED0',CAST(numero AS CHAR)));

            

        ELSEIF numero>=9999999  then 			set numero=numero+1;

		SET NEW.codigo_credito=(select concat('CRED',CAST(numero AS CHAR)));

            

		END IF;

    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `currency`
--

CREATE TABLE `currency` (
  `idcurrency` int(11) NOT NULL,
  `CurrencyISO` varchar(3) DEFAULT NULL,
  `Language` varchar(3) DEFAULT NULL,
  `CurrencyName` varchar(35) DEFAULT NULL,
  `Money` varchar(30) DEFAULT NULL,
  `Symbol` varchar(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `currency`
--

INSERT INTO `currency` (`idcurrency`, `CurrencyISO`, `Language`, `CurrencyName`, `Money`, `Symbol`) VALUES
(1, 'CRC', 'ES', 'Colon Costa Ricense', 'Colón', '₡'),
(2, 'HNL', 'ES', 'Lempira Hondureno', 'Lempira', 'L'),
(3, 'GTQ', 'ES', 'Quetzal', 'Quetzal', 'Q'),
(4, 'SVC', 'ES', 'Colon Salvadoreno', 'Colón', '₡'),
(5, 'NIC', 'ES', 'Cordoba Nicaraguense', 'Córdoba', 'C'),
(6, 'PEN', 'ES', 'SOLES PERUANOS', 'PEN', 'S/'),
(7, 'USD', 'EN', 'Dolar Estadounidense', 'US.Dolar', '$');

-- --------------------------------------------------------

--
-- Table structure for table `detalleapartado`
--

CREATE TABLE `detalleapartado` (
  `idapartado` int(11) NOT NULL,
  `idproducto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(13,2) NOT NULL,
  `fecha_vence` date DEFAULT NULL,
  `exento` decimal(13,2) NOT NULL,
  `descuento` decimal(13,2) NOT NULL,
  `importe` decimal(13,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `detallecompra`
--

CREATE TABLE `detallecompra` (
  `idcompra` int(11) NOT NULL,
  `idproducto` int(11) NOT NULL,
  `fecha_vence` date DEFAULT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(13,2) NOT NULL,
  `exento` decimal(13,2) NOT NULL,
  `importe` decimal(13,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detallecompra`
--

INSERT INTO `detallecompra` (`idcompra`, `idproducto`, `fecha_vence`, `cantidad`, `precio_unitario`, `exento`, `importe`) VALUES
(1, 1, NULL, 10, 20.00, 0.00, 200.00),
(2, 2, NULL, 1, 20.00, 20.00, 20.00),
(3, 3, NULL, 20, 49.99, 0.00, 999.80);

-- --------------------------------------------------------

--
-- Table structure for table `detallecotizacion`
--

CREATE TABLE `detallecotizacion` (
  `idcotizacion` int(11) NOT NULL,
  `idproducto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `disponible` tinyint(1) NOT NULL,
  `precio_unitario` decimal(13,2) NOT NULL,
  `exento` decimal(13,2) NOT NULL,
  `descuento` decimal(13,2) NOT NULL,
  `importe` decimal(13,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `detallecotizacion`
--

INSERT INTO `detallecotizacion` (`idcotizacion`, `idproducto`, `cantidad`, `disponible`, `precio_unitario`, `exento`, `descuento`, `importe`) VALUES
(1, 1, 1, 1, 40.00, 0.00, 0.00, 40.00),
(2, 1, 1, 1, 40.00, 0.00, 0.00, 40.00),
(2, 2, 1, 1, 30.00, 2.10, 0.00, 30.00),
(3, 1, 2, 1, 40.00, 0.00, 0.00, 80.00),
(4, 1, 1, 1, 40.00, 0.00, 0.00, 40.00),
(4, 2, 1, 1, 30.00, 2.10, 0.00, 30.00),
(5, 1, 1, 1, 40.00, 0.00, 0.00, 40.00),
(6, 1, 1, 1, 40.00, 0.00, 0.00, 40.00),
(7, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(7, 2, 0, 0, 1.00, 0.00, 0.00, 0.00),
(8, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(8, 2, 0, 0, 1.00, 0.00, 0.00, 0.00),
(9, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(10, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(11, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(12, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(13, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(14, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(15, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(16, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(17, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(17, 2, 0, 0, 1.00, 0.00, 0.00, 0.00),
(17, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(17, 2, 0, 0, 1.00, 0.00, 0.00, 0.00),
(18, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(18, 2, 0, 0, 1.00, 0.00, 0.00, 0.00),
(19, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(19, 2, 0, 0, 1.00, 0.00, 0.00, 0.00),
(20, 1, 0, 0, 0.00, 0.00, 0.00, 0.00),
(21, 1, 1, 0, 40.00, 0.00, 0.00, 40.00),
(22, 1, 1, 0, 40.00, 0.00, 0.00, 40.00),
(23, 1, 1, 0, 40.00, 0.00, 0.00, 40.00),
(23, 2, 1, 0, 30.00, 1.00, 0.00, 30.00),
(24, 2, 1, 0, 30.00, 1.00, 0.00, 30.00),
(24, 12, 1, 0, 18.32, 0.00, 0.00, 18.32);

-- --------------------------------------------------------

--
-- Table structure for table `detalleventa`
--

CREATE TABLE `detalleventa` (
  `idventa` int(11) NOT NULL,
  `idproducto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(13,2) NOT NULL,
  `fecha_vence` date DEFAULT NULL,
  `exento` decimal(13,2) NOT NULL,
  `descuento` decimal(13,2) NOT NULL,
  `importe` decimal(13,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detalleventa`
--

INSERT INTO `detalleventa` (`idventa`, `idproducto`, `cantidad`, `precio_unitario`, `fecha_vence`, `exento`, `descuento`, `importe`) VALUES
(1, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(2, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(3, 2, 1, 30.00, NULL, 30.00, 0.00, 30.00),
(4, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(5, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(6, 2, 2, 30.00, NULL, 4.20, 0.00, 60.00),
(7, 2, 3, 30.00, NULL, 6.30, 0.00, 90.00),
(8, 2, 2, 30.00, NULL, 4.20, 0.00, 60.00),
(9, 1, 3, 40.00, NULL, 0.00, 0.00, 120.00),
(10, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(11, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(12, 2, 2, 30.00, NULL, 4.20, 0.00, 60.00),
(13, 2, 3, 30.00, NULL, 6.30, 0.00, 90.00),
(14, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(15, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(15, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(16, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(16, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(17, 2, 5, 30.00, NULL, 10.50, 0.00, 150.00),
(18, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(19, 2, 2, 30.00, NULL, 4.20, 0.00, 60.00),
(20, 1, 2, 40.00, NULL, 0.00, 0.00, 80.00),
(21, 1, 2, 40.00, NULL, 0.00, 0.00, 80.00),
(22, 1, 2, 40.00, NULL, 0.00, 0.00, 80.00),
(23, 1, 2, 40.00, NULL, 0.00, 0.00, 80.00),
(24, 1, 2, 40.00, NULL, 0.00, 0.00, 80.00),
(25, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(26, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(27, 1, 2, 40.00, NULL, 0.00, 0.00, 80.00),
(29, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(29, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(30, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(30, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(31, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(31, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(32, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(32, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(33, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(33, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(34, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(34, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(35, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(35, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(36, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(36, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(37, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(37, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(38, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(38, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(39, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(39, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(40, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(40, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(41, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(41, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(42, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(42, 2, 1, 30.00, NULL, 2.10, 0.00, 30.00),
(43, 1, 1, 40.00, NULL, 0.00, 0.00, 0.00),
(44, 1, 2, 40.00, NULL, 0.00, 0.05, 0.00),
(44, 2, 2, 30.00, NULL, 1.00, 1.00, 0.00),
(45, 1, 1, 40.00, NULL, 0.00, 0.05, 0.00),
(45, 2, 2, 30.00, NULL, 1.00, 0.00, 0.00),
(46, 3, 10, 45.00, NULL, 0.00, 0.00, 0.00),
(47, 3, 10, 45.00, NULL, 0.00, 0.00, 0.00),
(48, 1, 2, 40.00, NULL, 0.00, 0.00, 0.00),
(48, 2, 2, 30.00, NULL, 1.00, 0.00, 0.00),
(49, 1, 2, 40.00, NULL, 0.00, 0.05, 0.00),
(49, 2, 2, 30.00, NULL, 1.00, 0.05, 0.00),
(50, 1, 2, 40.00, NULL, 0.00, 0.05, 0.00),
(50, 2, 2, 30.00, NULL, 1.00, 0.05, 0.00),
(51, 1, 2, 40.00, NULL, 0.00, 0.05, 0.00),
(52, 1, 2, 40.00, NULL, 0.00, 0.05, 0.00),
(53, 1, 2, 40.00, NULL, 0.00, 0.05, 0.00),
(54, 1, 1, 40.00, NULL, 0.00, 0.00, 0.00),
(55, 1, 1, 40.00, NULL, 0.00, 0.05, 0.00),
(61, 1, 1, 30.00, NULL, 0.00, 0.05, 0.00),
(62, 2, 2, 35.00, NULL, 1.00, 0.05, 0.00),
(63, 2, 2, 32.00, NULL, 1.00, 0.05, 0.00),
(64, 1, 2, 52.50, NULL, 0.00, 0.05, 0.00),
(64, 2, 1, 105.00, NULL, 1.00, 0.05, 0.00),
(65, 1, 2, 45.00, NULL, 0.00, 0.05, 0.00),
(65, 2, 1, 90.00, NULL, 1.00, 0.05, 0.00),
(66, 1, 2, 45.00, NULL, 0.00, 0.05, 0.00),
(66, 2, 1, 90.00, NULL, 1.00, 0.05, 0.00),
(67, 1, 2, 45.00, NULL, 0.00, 0.05, 0.00),
(67, 2, 1, 90.00, NULL, 1.00, 0.05, 0.00),
(68, 1, 2, 40.00, NULL, 0.00, 0.05, 0.00),
(68, 2, 1, 30.00, NULL, 1.00, 0.05, 0.00),
(69, 1, 2, 40.00, NULL, 0.00, 0.05, 0.00),
(69, 2, 1, 30.00, NULL, 1.00, 0.05, 0.00),
(70, 1, 2, 30.00, NULL, 0.00, 0.05, 0.00),
(70, 2, 1, 30.00, NULL, 1.00, 0.05, 0.00),
(71, 1, 3, 35.00, NULL, 0.00, 0.05, 0.00),
(71, 2, 2, 30.00, NULL, 1.00, 0.05, 0.00),
(72, 1, 3, 30.00, NULL, 0.00, 0.05, 0.00),
(72, 2, 2, 30.00, NULL, 1.00, 0.05, 0.00),
(73, 1, 1, 40.00, NULL, 0.00, 0.00, 0.00),
(74, 1, 1, 40.00, NULL, 0.00, 0.00, 0.00),
(75, 1, 1, 40.00, NULL, 0.00, 0.00, 0.00),
(76, 2, 5, 35.00, NULL, 1.00, 0.00, 0.00),
(77, 1, 5, 30.00, NULL, 0.00, 0.00, 0.00),
(78, 1, 1, 40.00, NULL, 0.00, 0.00, 0.00),
(79, 1, 1, 40.00, NULL, 0.00, 0.00, 40.00),
(80, 3, 1, 30.00, NULL, 0.00, 0.00, 30.00),
(81, 1, 2, 30.00, NULL, 0.00, 0.05, 60.00),
(81, 2, 2, 35.00, NULL, 1.00, 0.05, 70.00),
(82, 1, 2, 30.00, NULL, 0.00, 0.05, 60.00),
(82, 2, 2, 35.00, NULL, 1.00, 0.05, 70.00);

-- --------------------------------------------------------

--
-- Table structure for table `detalle_ordentaller`
--

CREATE TABLE `detalle_ordentaller` (
  `idDetalle` int(11) NOT NULL,
  `idorden` int(11) NOT NULL,
  `idproducto` int(11) NOT NULL,
  `precio` decimal(13,2) NOT NULL,
  `cantidad` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detalle_ordentaller`
--

INSERT INTO `detalle_ordentaller` (`idDetalle`, `idorden`, `idproducto`, `precio`, `cantidad`) VALUES
(27, 32, 1, 40.00, 3),
(29, 32, 2, 30.00, 1),
(30, 33, 1, 40.00, 2);

-- --------------------------------------------------------

--
-- Table structure for table `dias`
--

CREATE TABLE `dias` (
  `iddias` int(11) NOT NULL,
  `cantidad_dias` int(5) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dias`
--

INSERT INTO `dias` (`iddias`, `cantidad_dias`, `estado`) VALUES
(1, 15, 1),
(2, 30, 1),
(3, 60, 1),
(4, 120, 1);

-- --------------------------------------------------------

--
-- Table structure for table `empleado`
--

CREATE TABLE `empleado` (
  `idempleado` int(11) NOT NULL,
  `codigo_empleado` varchar(175) DEFAULT NULL,
  `nombre_empleado` varchar(90) NOT NULL,
  `apellido_empleado` varchar(90) NOT NULL,
  `telefono_empleado` varchar(70) NOT NULL,
  `email_empleado` varchar(80) DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1,
  `imagen` varchar(170) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `empleado`
--

INSERT INTO `empleado` (`idempleado`, `codigo_empleado`, `nombre_empleado`, `apellido_empleado`, `telefono_empleado`, `email_empleado`, `estado`, `imagen`) VALUES
(1, 'EM00000001', 'Juan', 'Perez', '985444754', 'tienda@empresa.com', 1, NULL),
(2, 'EM00000002', 'Maria', 'Rosas', '65896321', 'tienda2@empresa.com', 1, NULL),
(3, 'EM00000003', 'Ernesto', 'Guevara', '60606060', 'tienda3@empresa.com', 1, NULL),
(4, 'EM00000004', 'Julio', 'Verne', '9958565', 'tienda4@empresa.com', 1, NULL);

--
-- Triggers `empleado`
--
DELIMITER $$
CREATE TRIGGER `generar_codigo_empleado` BEFORE INSERT ON `empleado` FOR EACH ROW BEGIN

    

        DECLARE numero INT;

        

        SET numero = (SELECT max(idempleado) FROM empleado);

        

		IF numero IS NULL then

		  set numero=1;

        SET NEW.codigo_empleado='EM00000001';



		ELSEIF numero >= 1 and numero < 9 then

			set numero=numero+1;

		SET NEW.codigo_empleado=(select concat('EM0000000',CAST(numero AS CHAR)));

        

		ELSEIF numero >=9 and numero<=99 then

			set numero=numero+1;

		SET NEW.codigo_empleado=(select concat('EM000000',CAST(numero AS CHAR)));

            

		ELSEIF numero>=99 and numero<=999 then

			set numero=numero+1;

		SET NEW.codigo_empleado=(select concat('EM00000',CAST(numero AS CHAR)));

             

		ELSEIF numero>=999 and numero<=9999 then

		   set numero=numero+1;

		SET NEW.codigo_empleado=(select concat('EM0000',CAST(numero AS CHAR)));

           

		ELSEIF numero>=9999 and numero<=99999 then

			set numero=numero+1;

		SET NEW.codigo_empleado=(select concat('EM000',CAST(numero AS CHAR)));

             



		ELSEIF numero>=99999 and numero<=999999 then

			set numero=numero+1;

		SET NEW.codigo_empleado=(select concat('EM00',CAST(numero AS CHAR)));

            



		ELSEIF numero>=999999 and numero<=9999999 then

			set numero=numero+1;

		SET NEW.codigo_empleado=(select concat('EM0',CAST(numero AS CHAR)));

            

        ELSEIF numero>=9999999  then 			set numero=numero+1;

		SET NEW.codigo_empleado=(select concat('EM',CAST(numero AS CHAR)));

            

		END IF;

    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `entrada`
--

CREATE TABLE `entrada` (
  `identrada` int(11) NOT NULL,
  `mes_inventario` varchar(7) NOT NULL,
  `fecha_entrada` date NOT NULL,
  `descripcion_entrada` varchar(150) NOT NULL,
  `cantidad_entrada` int(11) NOT NULL,
  `precio_unitario_entrada` decimal(13,2) NOT NULL,
  `costo_total_entrada` decimal(13,2) NOT NULL,
  `idproducto` int(11) NOT NULL,
  `idcompra` int(11) DEFAULT NULL,
  `idapartado` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `entrada`
--

INSERT INTO `entrada` (`identrada`, `mes_inventario`, `fecha_entrada`, `descripcion_entrada`, `cantidad_entrada`, `precio_unitario_entrada`, `costo_total_entrada`, `idproducto`, `idcompra`, `idapartado`) VALUES
(1, '2024-07', '2024-07-04', 'INVENTARIO INICIAL', 10, 20.00, 200.00, 1, NULL, NULL),
(2, '2024-07', '2024-07-04', 'POR COMPRA TICKET # 1', 10, 20.00, 200.00, 1, 1, NULL),
(3, '2024-07', '2024-07-04', 'INVENTARIO INICIAL', 50, 20.00, 1000.00, 2, NULL, NULL),
(4, '2024-07', '2024-07-05', 'POR COMPRA TICKET # 2', 1, 20.00, 20.00, 2, 2, NULL),
(5, '2024-10', '2024-10-14', 'INVENTARIO INICIAL', 20, 49.99, 999.80, 3, NULL, NULL),
(6, '2024-11', '2024-11-01', 'POR COMPRA TICKET # 1', 20, 49.99, 999.80, 3, 3, NULL),
(7, '2024-12', '2024-12-17', 'INVENTARIO INICIAL', 55, 200.00, 11000.00, 4, NULL, NULL),
(8, '2024-12', '2024-12-17', 'INVENTARIO INICIAL', 55, 200.00, 11000.00, 5, NULL, NULL),
(9, '2024-12', '2024-12-18', 'INVENTARIO INICIAL', 55, 15.50, 852.50, 6, NULL, NULL),
(10, '2024-12', '2024-12-18', 'INVENTARIO INICIAL', 55, 15.50, 852.50, 7, NULL, NULL),
(11, '2024-12', '2024-12-18', 'INVENTARIO INICIAL', 55, 15.50, 852.50, 8, NULL, NULL),
(12, '2024-12', '2024-12-18', 'INVENTARIO INICIAL', 55, 15.50, 852.50, 9, NULL, NULL),
(13, '2024-12', '2024-12-18', 'INVENTARIO INICIAL', 55, 15.50, 852.50, 10, NULL, NULL),
(14, '2024-12', '2024-12-18', 'INVENTARIO INICIAL', 55, 200.00, 11000.00, 11, NULL, NULL),
(15, '2024-12', '2024-12-18', 'INVENTARIO INICIAL', 55, 15.50, 852.50, 12, NULL, NULL),
(16, '2024-12', '2024-12-18', 'INVENTARIO INICIAL', 55, 15.50, 852.50, 13, NULL, NULL),
(17, '2024-12', '2024-12-18', 'INVENTARIO INICIAL', 55, 15.50, 852.50, 14, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `historial`
--

CREATE TABLE `historial` (
  `idhistorial` int(11) NOT NULL,
  `num_historial` varchar(175) NOT NULL,
  `codigo_interno` varchar(175) NOT NULL,
  `codigo_barra` varchar(200) DEFAULT NULL,
  `codigo_alternativo` varchar(200) DEFAULT NULL,
  `idproducto` int(11) NOT NULL,
  `nombre_producto` varchar(175) NOT NULL,
  `tipo_movimiento` varchar(100) NOT NULL,
  `stock_actual` int(11) NOT NULL,
  `stock_anterior` int(11) NOT NULL,
  `fecha_movimiento` datetime NOT NULL,
  `idusuario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `historial`
--

INSERT INTO `historial` (`idhistorial`, `num_historial`, `codigo_interno`, `codigo_barra`, `codigo_alternativo`, `idproducto`, `nombre_producto`, `tipo_movimiento`, `stock_actual`, `stock_anterior`, `fecha_movimiento`, `idusuario`) VALUES
(1, 'HI00000001', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'NUEVO PRODUCTO', 10, 0, '2024-07-04 10:49:22', 1),
(2, 'HI00000002', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 20, 10, '2024-07-04 10:51:42', 1),
(3, 'HI00000003', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 19, 20, '2024-07-04 11:18:37', 1),
(4, 'HI00000004', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 18, 19, '2024-07-04 11:23:07', 1),
(5, 'HI00000005', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'NUEVO PRODUCTO', 50, 0, '2024-07-04 11:53:54', 1),
(6, 'HI00000006', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 49, 50, '2024-07-04 11:55:50', 1),
(7, 'HI00000007', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 50, 49, '2024-07-05 14:08:28', 1),
(8, 'HI00000008', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 17, 18, '2024-07-06 20:01:07', 1),
(9, 'HI00000009', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 49, 50, '2024-07-06 20:05:36', 1),
(10, 'HI00000010', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 47, 49, '2024-07-06 20:29:38', 1),
(11, 'HI00000011', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 44, 47, '2024-07-06 20:35:14', 1),
(12, 'HI00000012', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 14, 17, '2024-07-07 02:49:44', 1),
(13, 'HI00000013', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 42, 44, '2024-07-07 03:03:21', 1),
(14, 'HI00000014', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 39, 42, '2024-07-08 10:13:22', 1),
(15, 'HI00000015', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 37, 39, '2024-07-08 10:24:13', 1),
(16, 'HI00000016', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 36, 37, '2024-07-08 10:34:48', 1),
(17, 'HI00000017', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 13, 14, '2024-07-08 10:39:45', 1),
(18, 'HI00000018', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 35, 36, '2024-07-08 10:44:31', 1),
(19, 'HI00000019', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 12, 13, '2024-07-08 11:04:14', 1),
(20, 'HI00000020', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 11, 12, '2024-07-08 11:32:28', 1),
(21, 'HI00000021', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 32, 35, '2024-07-08 11:50:56', 1),
(22, 'HI00000022', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 31, 32, '2024-07-08 11:51:19', 1),
(23, 'HI00000023', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 10, 11, '2024-07-24 09:26:09', 1),
(24, 'HI00000024', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 29, 31, '2024-07-24 11:07:52', 1),
(25, 'HI00000025', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 8, 10, '2024-07-24 11:37:30', 1),
(26, 'HI00000026', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 6, 8, '2024-07-25 15:07:15', 1),
(27, 'HI00000027', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 5, 6, '2024-07-26 15:14:20', 1),
(28, 'HI00000028', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 28, 29, '2024-07-26 15:14:20', 1),
(29, 'HI00000029', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 4, 5, '2024-07-31 20:08:16', 1),
(30, 'HI00000030', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 26, 28, '2024-07-31 20:08:16', 1),
(31, 'HI00000031', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 50, 4, '2024-08-01 09:39:29', 1),
(32, 'HI00000032', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 50, 26, '2024-08-01 09:39:35', 1),
(33, 'HI00000033', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 48, 50, '2024-08-01 09:44:58', 1),
(34, 'HI00000034', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 49, 50, '2024-08-01 09:44:58', 1),
(35, 'HI00000035', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 1000, 48, '2024-08-01 09:59:12', 1),
(36, 'HI00000036', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 1000, 49, '2024-08-01 09:59:17', 1),
(37, 'HI00000037', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 997, 1000, '2024-08-01 10:05:29', 1),
(38, 'HI00000038', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 999, 1000, '2024-08-01 10:05:29', 1),
(39, 'HI00000039', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 997, 999, '2024-08-01 11:02:51', 1),
(40, 'HI00000040', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 994, 997, '2024-08-01 11:02:52', 1),
(41, 'HI00000041', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 992, 994, '2024-08-01 11:14:53', 1),
(42, 'HI00000042', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 996, 997, '2024-08-01 11:14:54', 1),
(43, 'HI00000043', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 994, 996, '2024-08-01 11:22:21', 1),
(44, 'HI00000044', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 988, 992, '2024-08-01 11:22:21', 1),
(45, 'HI00000045', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 986, 988, '2024-08-01 12:17:53', 1),
(46, 'HI00000046', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 990, 994, '2024-08-01 12:17:53', 1),
(47, 'HI00000047', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 985, 986, '2024-08-01 12:50:06', 1),
(48, 'HI00000048', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 989, 990, '2024-08-01 12:50:06', 1),
(49, 'HI00000049', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 983, 985, '2024-08-01 14:08:41', 1),
(50, 'HI00000050', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 988, 989, '2024-08-01 14:08:41', 1),
(51, 'HI00000051', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 981, 983, '2024-08-01 14:19:54', 1),
(52, 'HI00000052', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 985, 988, '2024-08-01 14:19:54', 1),
(53, 'HI00000053', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 977, 981, '2024-08-01 14:28:58', 1),
(54, 'HI00000054', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 980, 985, '2024-08-01 14:28:58', 1),
(55, 'HI00000055', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 975, 977, '2024-08-01 14:49:17', 1),
(56, 'HI00000056', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 979, 980, '2024-08-01 14:49:17', 1),
(57, 'HI00000057', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 973, 975, '2024-08-02 14:10:53', 1),
(58, 'HI00000058', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 976, 979, '2024-08-02 14:10:53', 1),
(59, 'HI00000059', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA PRODUCTO', 973, 973, '2024-08-05 12:01:34', 1),
(60, 'HI00000060', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA PRODUCTO', 976, 976, '2024-08-05 12:01:34', 1),
(61, 'HI00000061', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA PRODUCTO', 973, 973, '2024-08-05 12:05:03', 1),
(62, 'HI00000062', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA PRODUCTO', 976, 976, '2024-08-05 12:05:03', 1),
(63, 'HI00000063', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA PRODUCTO', 973, 973, '2024-08-05 12:07:22', 1),
(64, 'HI00000064', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA PRODUCTO', 976, 976, '2024-08-05 12:07:22', 1),
(65, 'HI00000065', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 979, 976, '2024-08-06 11:04:20', 1),
(66, 'HI00000066', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 970, 973, '2024-08-06 12:05:29', 1),
(67, 'HI00000067', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 974, 979, '2024-08-06 12:05:29', 1),
(68, 'HI00000068', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 979, 974, '2024-08-06 14:31:54', 1),
(69, 'HI00000069', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA PRODUCTO', 970, 970, '2024-08-06 14:31:54', 1),
(70, 'HI00000070', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA PRODUCTO', 970, 970, '2024-08-06 14:36:15', 1),
(71, 'HI00000071', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 978, 979, '2024-08-06 14:36:15', 1),
(72, 'HI00000072', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 968, 970, '2024-08-06 15:09:01', 1),
(73, 'HI00000073', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA PRODUCTO', 968, 968, '2024-08-06 15:27:00', 1),
(74, 'HI00000074', 'PR00000003', '3', '3', 3, 'CASE TORRE C', 'NUEVO PRODUCTO', 20, 0, '2024-10-14 09:46:13', 1),
(75, 'HI00000075', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 966, 967, '2024-11-01 10:09:08', 1),
(76, 'HI00000076', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 975, 977, '2024-11-01 10:09:08', 1),
(77, 'HI00000077', 'PR00000003', '3', '3', 3, 'CASE TORRE C', 'ACTUALIZA: STOCK', 10, 20, '2024-11-01 10:30:23', 1),
(78, 'HI00000078', 'PR00000003', '3', '3', 3, 'CASE TORRE C', 'ACTUALIZA: STOCK', 0, 10, '2024-11-01 10:31:46', 1),
(79, 'HI00000079', 'PR00000003', '3', '3', 3, 'CASE TORRE C', 'ACTUALIZA: STOCK', 20, 0, '2024-11-01 11:00:04', 1),
(80, 'HI00000080', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 964, 966, '2024-11-01 11:51:30', 1),
(81, 'HI00000081', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 962, 964, '2024-11-06 15:18:43', 1),
(82, 'HI00000082', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 970, 975, '2024-11-06 15:37:15', 1),
(83, 'HI00000083', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 960, 962, '2024-11-06 15:40:45', 1),
(84, 'HI00000084', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 968, 970, '2024-11-06 15:40:45', 1),
(85, 'HI00000085', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 958, 960, '2024-11-06 15:41:53', 1),
(86, 'HI00000086', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 957, 958, '2024-11-06 15:42:05', 1),
(87, 'HI00000087', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 955, 957, '2024-11-06 15:49:47', 1),
(88, 'HI00000088', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 966, 968, '2024-11-06 15:49:47', 1),
(89, 'HI00000089', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 953, 955, '2024-11-06 15:53:49', 1),
(90, 'HI00000090', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 964, 966, '2024-11-06 15:53:49', 1),
(91, 'HI00000091', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 951, 953, '2024-11-08 08:32:16', 1),
(92, 'HI00000092', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 962, 964, '2024-11-08 08:45:38', 1),
(93, 'HI00000093', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 949, 951, '2024-11-08 15:37:05', 1),
(94, 'HI00000094', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 948, 949, '2024-11-12 09:53:40', 1),
(95, 'HI00000095', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 947, 948, '2024-11-15 12:57:26', 1),
(96, 'HI00000096', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 946, 947, '2024-11-15 15:02:05', 1),
(97, 'HI00000097', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 960, 962, '2024-11-15 15:11:11', 1),
(98, 'HI00000098', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 944, 946, '2024-11-15 15:13:06', 1),
(99, 'HI00000099', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 958, 960, '2024-11-15 15:14:18', 1),
(100, 'HI00000100', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 942, 944, '2024-11-15 15:17:12', 1),
(101, 'HI00000101', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 957, 958, '2024-11-15 15:17:12', 1),
(102, 'HI00000102', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 940, 942, '2024-11-15 15:59:25', 1),
(103, 'HI00000103', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 956, 957, '2024-11-15 15:59:25', 1),
(104, 'HI00000104', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 938, 940, '2024-11-15 16:01:31', 1),
(105, 'HI00000105', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 955, 956, '2024-11-15 16:01:31', 1),
(106, 'HI00000106', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 936, 938, '2024-11-16 20:22:41', 1),
(107, 'HI00000107', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 954, 955, '2024-11-16 20:22:41', 1),
(108, 'HI00000108', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 934, 936, '2024-11-16 20:24:02', 1),
(109, 'HI00000109', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 953, 954, '2024-11-16 20:24:02', 1),
(110, 'HI00000110', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 932, 934, '2024-11-16 20:52:50', 1),
(111, 'HI00000111', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 952, 953, '2024-11-16 20:52:50', 1),
(112, 'HI00000112', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 929, 932, '2024-11-16 21:02:16', 1),
(113, 'HI00000113', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 950, 952, '2024-11-16 21:02:16', 1),
(114, 'HI00000114', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 926, 929, '2024-11-16 21:05:16', 1),
(115, 'HI00000115', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 948, 950, '2024-11-16 21:05:16', 1),
(116, 'HI00000116', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 943, 948, '2024-11-20 09:53:13', 1),
(117, 'HI00000117', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 924, 926, '2024-12-10 12:49:35', 1),
(118, 'HI00000118', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 941, 943, '2024-12-10 12:49:35', 1),
(119, 'HI00000119', 'PR00000003', '3', '3', 3, 'CASE TORRE C', 'ACTUALIZA: STOCK', 19, 20, '2024-12-10 12:49:49', 1),
(120, 'HI00000120', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 922, 924, '2024-12-10 12:51:04', 1),
(121, 'HI00000121', 'PR00000002', '2', '2', 2, 'CASE TORRE 2', 'ACTUALIZA: STOCK', 939, 941, '2024-12-10 12:51:04', 1),
(122, 'HI00000122', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: STOCK', 921, 922, '2024-12-10 12:51:37', 1),
(123, 'HI00000123', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: PRECIO DE VENTA 2', 921, 921, '2024-12-17 12:18:11', 1),
(124, 'HI00000124', 'PR00000002', '2', '2', 2, 'RETROVISOR B', 'ACTUALIZA: NOMBRE DEL PRODUCTO', 939, 939, '2024-12-17 12:18:37', 1),
(125, 'HI00000125', 'PR00000004', '4', '4', 4, 'AMORTIGUADOR X', 'NUEVO PRODUCTO', 55, 0, '2024-12-17 12:22:47', 1),
(126, 'HI00000126', 'PR00000005', '5', '5', 5, 'RIN Z', 'NUEVO PRODUCTO', 55, 0, '2024-12-17 13:02:12', 1),
(127, 'HI00000127', 'PR00000006', '6', '6', 6, 'CASE TORRE E', 'NUEVO PRODUCTO', 55, 0, '2024-12-18 08:26:05', 1),
(128, 'HI00000128', 'PR00000007', '7', '7', 7, 'RADIO V', 'NUEVO PRODUCTO', 55, 0, '2024-12-18 08:51:48', 1),
(129, 'HI00000129', 'PR00000008', '8', '8', 8, 'RADIO Z', 'NUEVO PRODUCTO', 55, 0, '2024-12-18 08:52:52', 1),
(130, 'HI00000130', 'PR00000009', '9', '9', 9, 'RADIO Z', 'NUEVO PRODUCTO', 55, 0, '2024-12-18 08:55:36', 1),
(131, 'HI00000131', 'PR00000001', '1', '1', 1, 'CASE TORRE A', 'ACTUALIZA: PRECIO DE COMPRA; PRECIO DE VENTA 1; PRECIO DE VENTA 3; STOCK MINIMO', 921, 921, '2024-12-18 09:12:23', 1),
(132, 'HI00000132', 'PR00000010', '10', '10', 10, 'RETROVISOR X', 'NUEVO PRODUCTO', 55, 0, '2024-12-18 11:18:54', 1),
(133, 'HI00000133', 'PR00000011', '11', '11', 11, 'RIN A', 'NUEVO PRODUCTO', 55, 0, '2024-12-18 11:31:37', 1),
(134, 'HI00000134', 'PR00000012', '12', '12', 12, 'RETROVISOR X', 'NUEVO PRODUCTO', 55, 0, '2024-12-18 11:52:14', 1),
(135, 'HI00000135', 'PR00000013', '13', '13', 13, 'RETROVISOR X', 'NUEVO PRODUCTO', 55, 0, '2024-12-18 12:33:17', 1),
(136, 'HI00000136', 'PR00000014', '14', '14', 14, 'RETROVISOR X', 'NUEVO PRODUCTO', 55, 0, '2024-12-18 12:40:26', 1);

-- --------------------------------------------------------

--
-- Table structure for table `inventario`
--

CREATE TABLE `inventario` (
  `mes_inventario` varchar(7) DEFAULT NULL,
  `fecha_apertura` date NOT NULL,
  `fecha_cierre` date NOT NULL,
  `saldo_inicial` decimal(13,2) NOT NULL,
  `entradas` int(11) DEFAULT NULL,
  `salidas` int(11) DEFAULT NULL,
  `saldo_final` decimal(13,2) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1,
  `idproducto` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inventario`
--

INSERT INTO `inventario` (`mes_inventario`, `fecha_apertura`, `fecha_cierre`, `saldo_inicial`, `entradas`, `salidas`, `saldo_final`, `estado`, `idproducto`) VALUES
('2024-07', '2024-07-01', '2024-07-31', 10.00, 20, 51, -31.00, 1, 1),
('2024-07', '2024-07-01', '2024-07-31', 50.00, 51, 51, 0.00, 1, 2),
('2024-10', '2024-10-01', '2024-10-31', 968.00, 0, 3, 965.00, 1, 1),
('2024-10', '2024-10-01', '2024-10-31', 978.00, 0, 2, 976.00, 1, 2),
('2024-10', '2024-10-01', '2024-10-31', 20.00, 20, 0, 20.00, 1, 3),
('2024-11', '2024-11-01', '2024-11-30', 967.00, 0, 46, 921.00, 1, 1),
('2024-11', '2024-11-01', '2024-11-30', 977.00, 0, 28, 949.00, 1, 2),
('2024-11', '2024-11-01', '2024-11-30', 20.00, 20, 21, 19.00, 1, 3),
('2024-12', '2024-12-01', '2024-12-31', 926.00, 0, 4, 922.00, 1, 1),
('2024-12', '2024-12-01', '2024-12-31', 943.00, 0, 4, 939.00, 1, 2),
('2024-12', '2024-12-01', '2024-12-31', 20.00, 0, 0, 20.00, 1, 3),
('2024-12', '2024-12-01', '2024-12-31', 55.00, 55, 0, 55.00, 1, 4),
('2024-12', '2024-12-01', '2024-12-31', 55.00, 55, 0, 55.00, 1, 5),
('2024-12', '2024-12-01', '2024-12-31', 55.00, 55, 0, 55.00, 1, 6),
('2024-12', '2024-12-01', '2024-12-31', 55.00, 55, 0, 55.00, 1, 7),
('2024-12', '2024-12-01', '2024-12-31', 55.00, 55, 0, 55.00, 1, 8),
('2024-12', '2024-12-01', '2024-12-31', 55.00, 55, 0, 55.00, 1, 9),
('2024-12', '2024-12-01', '2024-12-31', 55.00, 55, 0, 55.00, 1, 10),
('2024-12', '2024-12-01', '2024-12-31', 55.00, 55, 0, 55.00, 1, 11),
('2024-12', '2024-12-01', '2024-12-31', 55.00, 55, 0, 55.00, 1, 12),
('2024-12', '2024-12-01', '2024-12-31', 55.00, 55, 0, 55.00, 1, 13),
('2024-12', '2024-12-01', '2024-12-31', 55.00, 55, 0, 55.00, 1, 14);

-- --------------------------------------------------------

--
-- Table structure for table `marca`
--

CREATE TABLE `marca` (
  `idmarca` int(11) NOT NULL,
  `nombre_marca` varchar(120) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `marca`
--

INSERT INTO `marca` (`idmarca`, `nombre_marca`, `estado`) VALUES
(1, 'MERCEDEZ', 1),
(2, 'BMW', 1),
(3, 'PORSCHE', 1),
(4, 'LEXUS', 1);

-- --------------------------------------------------------

--
-- Table structure for table `ordentaller`
--

CREATE TABLE `ordentaller` (
  `idorden` int(11) NOT NULL,
  `numero_orden` varchar(175) DEFAULT NULL,
  `fecha_ingreso` datetime NOT NULL,
  `idcliente` int(11) NOT NULL,
  `aparato` varchar(125) NOT NULL,
  `modelo` varchar(125) DEFAULT NULL,
  `idmarca` int(11) NOT NULL,
  `Placa` varchar(125) DEFAULT NULL,
  `idtecnico` int(11) NOT NULL,
  `averia` varchar(200) NOT NULL,
  `observaciones` varchar(200) DEFAULT NULL,
  `deposito_revision` int(11) NOT NULL DEFAULT 0,
  `deposito_reparacion` int(11) DEFAULT 0,
  `diagnostico` varchar(200) NOT NULL,
  `estado_aparato` varchar(200) NOT NULL,
  `repuestos` int(11) NOT NULL DEFAULT 0,
  `mano_obra` decimal(13,2) DEFAULT 0.00,
  `fecha_alta` datetime DEFAULT NULL,
  `fecha_retiro` datetime DEFAULT NULL,
  `ubicacion` varchar(150) DEFAULT NULL,
  `parcial_pagar` decimal(13,2) NOT NULL DEFAULT 0.00,
  `montoRepuesto` decimal(13,2) DEFAULT NULL,
  `ManoObra` decimal(13,2) NOT NULL,
  `horaObra` int(11) DEFAULT 0,
  `AnioAuto` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ordentaller`
--

INSERT INTO `ordentaller` (`idorden`, `numero_orden`, `fecha_ingreso`, `idcliente`, `aparato`, `modelo`, `idmarca`, `Placa`, `idtecnico`, `averia`, `observaciones`, `deposito_revision`, `deposito_reparacion`, `diagnostico`, `estado_aparato`, `repuestos`, `mano_obra`, `fecha_alta`, `fecha_retiro`, `ubicacion`, `parcial_pagar`, `montoRepuesto`, `ManoObra`, `horaObra`, `AnioAuto`) VALUES
(32, '00000001', '2024-08-06 11:46:05', 1, '', 'AB34', 1, 'CVBNFG', 1, 'LA AVERÍA', 'LAS OBSERVACIONES', 0, 0, 'EL DIAGNOSTICO', 'EL ESTADO', 150, 12.00, '2024-08-05 12:03:27', '2024-08-06 12:03:34', 'LA UBICACIÓN', 162.00, 0.00, 0.00, 0, 2020),
(33, '00000033', '2024-08-06 14:39:36', 1, '', '43R4', 3, 'FDSFS', 1, 'XCVDSVFD', 'DWQDWQD', 0, 0, 'PRUEBA DE CANTIDAD', 'DEDEDE', 80, 5.00, '2024-08-05 15:07:57', '2024-08-06 15:07:58', 'RFRFR', 85.00, 0.00, 0.00, 1, 2005);

--
-- Triggers `ordentaller`
--
DELIMITER $$
CREATE TRIGGER `generar_codigo_ordentaller` BEFORE INSERT ON `ordentaller` FOR EACH ROW BEGIN

    

        DECLARE numero INT;

        

        SET numero = (SELECT max(idorden) FROM ordentaller);

 

		IF numero IS NULL then

		  set numero=1;

        SET NEW.numero_orden ='00000001';



		ELSEIF numero >= 1 and numero < 9 then

			set numero=numero+1;

		SET NEW.numero_orden =(select concat('0000000',CAST(numero AS CHAR)));

        

		ELSEIF numero >=9 and numero<=99 then

			set numero=numero+1;

		SET NEW.numero_orden =(select concat('000000',CAST(numero AS CHAR)));

            

		ELSEIF numero>=99 and numero<=999 then

			set numero=numero+1;

		SET NEW.numero_orden =(select concat('00000',CAST(numero AS CHAR)));

             

		ELSEIF numero>=999 and numero<=9999 then

		   set numero=numero+1;

		SET NEW.numero_orden =(select concat('0000',CAST(numero AS CHAR)));

           


		ELSEIF numero>=9999 and numero<=99999 then

			set numero=numero+1;

		SET NEW.numero_orden =(select concat('000',CAST(numero AS CHAR)));

             



		ELSEIF numero>=99999 and numero<=999999 then

			set numero=numero+1;

		SET NEW.numero_orden =(select concat('00',CAST(numero AS CHAR)));

            



		ELSEIF numero>=999999 and numero<=9999999 then

			set numero=numero+1;

		SET NEW.numero_orden =(select concat('0',CAST(numero AS CHAR)));

            

        ELSEIF numero>=9999999  then 			set numero=numero+1;

		SET NEW.numero_orden =(numero);

            

		END IF;

        

    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `parametro`
--

CREATE TABLE `parametro` (
  `idparametro` int(11) NOT NULL,
  `nombre_empresa` varchar(150) NOT NULL,
  `propietario` varchar(150) NOT NULL,
  `numero_nit` varchar(70) NOT NULL,
  `numero_nrc` varchar(70) DEFAULT NULL,
  `porcentaje_iva` decimal(13,2) NOT NULL,
  `porcentaje_retencion` decimal(13,2) DEFAULT NULL,
  `monto_retencion` decimal(13,2) DEFAULT NULL,
  `direccion_empresa` varchar(200) NOT NULL,
  `logo_empresa` varchar(90) DEFAULT NULL,
  `idcurrency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `parametro`
--

INSERT INTO `parametro` (`idparametro`, `nombre_empresa`, `propietario`, `numero_nit`, `numero_nrc`, `porcentaje_iva`, `porcentaje_retencion`, `monto_retencion`, `direccion_empresa`, `logo_empresa`, `idcurrency`) VALUES
(1, 'SILVER', 'autopartes', 'TEL: (507)831-7293', '155664020-2-2018 DV 58', 7.00, 0.00, 0.00, 'Parque Lefevre, calle 9 local #5', NULL, 7);

-- --------------------------------------------------------

--
-- Table structure for table `perecedero`
--

CREATE TABLE `perecedero` (
  `fecha_vencimiento` date NOT NULL,
  `cantidad_perecedero` decimal(13,2) NOT NULL,
  `idproducto` int(11) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `presentacion`
--

CREATE TABLE `presentacion` (
  `idpresentacion` int(11) NOT NULL,
  `nombre_presentacion` varchar(120) NOT NULL,
  `siglas` varchar(45) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `presentacion`
--

INSERT INTO `presentacion` (`idpresentacion`, `nombre_presentacion`, `siglas`, `estado`) VALUES
(1, 'UNIDAD', 'UN', 1),
(2, 'PACK', 'PK', 1),
(3, 'CAJA', 'CJ', 1);

-- --------------------------------------------------------

--
-- Table structure for table `producto`
--

CREATE TABLE `producto` (
  `idproducto` int(11) NOT NULL,
  `codigo_interno` varchar(175) DEFAULT NULL,
  `codigo_barra` varchar(200) DEFAULT NULL,
  `codigo_alternativo` varchar(200) DEFAULT NULL,
  `nombre_producto` varchar(175) NOT NULL,
  `precio_compra` decimal(13,2) NOT NULL,
  `precio_venta` decimal(13,2) NOT NULL,
  `precio_venta1` decimal(13,2) DEFAULT NULL,
  `precio_venta2` decimal(13,2) DEFAULT NULL,
  `precio_venta3` decimal(13,2) DEFAULT NULL,
  `precio_venta_mayoreo` decimal(13,2) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `stock_min` int(11) NOT NULL DEFAULT 1,
  `idcategoria` int(11) NOT NULL,
  `idmarca` int(11) DEFAULT NULL,
  `idpresentacion` int(11) NOT NULL DEFAULT 1,
  `estado` tinyint(1) NOT NULL DEFAULT 1,
  `exento` tinyint(1) NOT NULL DEFAULT 0,
  `inventariable` tinyint(1) NOT NULL DEFAULT 1,
  `perecedero` tinyint(1) DEFAULT 0,
  `imagen` varchar(170) DEFAULT NULL,
  `usuario` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `producto`
--

INSERT INTO `producto` (`idproducto`, `codigo_interno`, `codigo_barra`, `codigo_alternativo`, `nombre_producto`, `precio_compra`, `precio_venta`, `precio_venta1`, `precio_venta2`, `precio_venta3`, `precio_venta_mayoreo`, `stock`, `stock_min`, `idcategoria`, `idmarca`, `idpresentacion`, `estado`, `exento`, `inventariable`, `perecedero`, `imagen`, `usuario`) VALUES
(1, 'PR00000001', '1', '1', 'CASE TORRE A', 25.00, 40.00, 50.00, 100.00, 45.00, 30.00, 921, 15, 1, 1, 1, 1, 0, 1, 0, 'imgepd.jpg', 1),
(2, 'PR00000002', '2', '2', 'RETROVISOR B', 20.00, 30.00, 32.00, 33.00, 35.00, 25.00, 939, 20, 1, 2, 1, 1, 1, 1, 0, '', 1),
(3, 'PR00000003', '3', '3', 'CASE TORRE C', 49.99, 45.00, 40.00, 30.00, 0.00, 20.00, 19, 5, 1, 3, 1, 1, 0, 1, 0, '', 1),
(4, 'PR00000004', '4', '4', 'AMORTIGUADOR X', 200.00, 280.00, 290.00, 300.00, 310.00, 250.00, 55, 5, 1, 3, 1, 1, 0, 1, 0, '', 1),
(5, 'PR00000005', '5', '5', 'RIN Z', 200.00, 280.00, 290.00, 300.00, 310.00, 250.00, 55, 5, 1, 3, 1, 1, 0, 1, 0, '', 1),
(6, 'PR00000006', '6', '6', 'CASE TORRE E', 15.50, 18.32, 19.99, 15.56, 18.00, 12.00, 55, 5, 1, 3, 1, 1, 0, 1, 0, 'bocina2.jpg', 1),
(7, 'PR00000007', '7', '7', 'RADIO V', 15.50, 18.32, 19.99, 15.56, 18.00, 12.00, 55, 5, 1, 3, 1, 1, 0, 1, 0, 'bocina2.jpg', 1),
(8, 'PR00000008', '8', '8', 'RADIO Z', 15.50, 18.32, 19.99, 15.56, 18.00, 12.00, 55, 5, 1, 3, 1, 1, 0, 1, 0, 'bocina2.jpg', 1),
(9, 'PR00000009', '9', '9', 'RADIO Z', 15.50, 18.32, 19.99, 15.56, 18.00, 12.00, 55, 5, 1, 3, 1, 1, 0, 1, 0, 'bocina2.jpg', 1),
(10, 'PR00000010', '10', '10', 'RETROVISOR X', 15.50, 18.32, 19.99, 15.56, 18.00, 12.00, 55, 5, 1, 3, 1, 1, 0, 1, 0, NULL, 1),
(11, 'PR00000011', '11', '11', 'RIN A', 200.00, 280.00, 290.00, 300.00, 310.00, 250.00, 55, 5, 1, 3, 1, 1, 0, 1, 0, '', 1),
(12, 'PR00000012', '12', '12', 'RETROVISOR X', 15.50, 18.32, 19.99, 15.56, 18.00, 12.00, 55, 5, 1, 3, 1, 1, 0, 1, 0, 'bocina2.jpg', 1),
(13, 'PR00000013', '13', '13', 'RETROVISOR X', 15.50, 18.32, 19.99, 15.56, 18.00, 12.00, 55, 5, 1, 3, 1, 1, 0, 1, 0, 'bocina2.jpg', 1),
(14, 'PR00000014', '14', '14', 'RETROVISOR X', 15.50, 18.32, 19.99, 15.56, 18.00, 12.00, 55, 5, 1, 3, 1, 1, 0, 1, 0, 'bocina2.jpg', 1);

--
-- Triggers `producto`
--
DELIMITER $$
CREATE TRIGGER `generar_codigo_producto` BEFORE INSERT ON `producto` FOR EACH ROW BEGIN

    

        DECLARE numero INT;



        SET numero = (SELECT max(idproducto) FROM producto);

        

		IF numero IS NULL then

		  set numero=1;

        SET NEW.codigo_interno='PR00000001';



		ELSEIF numero >= 1 and numero < 9 then

			set numero=numero+1;

		SET NEW.codigo_interno=(select concat('PR0000000',CAST(numero AS CHAR)));

        

		ELSEIF numero >=9 and numero<=99 then

			set numero=numero+1;

		SET NEW.codigo_interno=(select concat('PR000000',CAST(numero AS CHAR)));

            

		ELSEIF numero>=99 and numero<=999 then

			set numero=numero+1;

		SET NEW.codigo_interno=(select concat('PR00000',CAST(numero AS CHAR)));

             

		ELSEIF numero>=999 and numero<=9999 then

		   set numero=numero+1;

		SET NEW.codigo_interno=(select concat('PR0000',CAST(numero AS CHAR)));

           

		ELSEIF numero>=9999 and numero<=99999 then

			set numero=numero+1;

		SET NEW.codigo_interno=(select concat('PR000',CAST(numero AS CHAR)));

             



		ELSEIF numero>=99999 and numero<=999999 then

			set numero=numero+1;

		SET NEW.codigo_interno=(select concat('PR00',CAST(numero AS CHAR)));

            



		ELSEIF numero>=999999 and numero<=9999999 then

			set numero=numero+1;

		SET NEW.codigo_interno=(select concat('PR0',CAST(numero AS CHAR)));

            

        ELSEIF numero>=9999999  then 			set numero=numero+1;

		SET NEW.codigo_interno=(select concat('PR',CAST(numero AS CHAR)));

            

		END IF;

    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insertar_nuevo_producto_historial` AFTER INSERT ON `producto` FOR EACH ROW BEGIN
    DECLARE p_codigo_interno VARCHAR(175);
    DECLARE p_codigo_barra VARCHAR(200);
    DECLARE p_codigo_alternativo VARCHAR(200);
    DECLARE p_idproducto INT;
    DECLARE p_nombre_producto VARCHAR(175);
    DECLARE p_tipo_movimiento VARCHAR(100);
    DECLARE p_stock_actual INT;
    DECLARE p_stock_anterior INT;
    DECLARE p_idusuario INT;
    DECLARE p_salidas INT;
    DECLARE numero INT;
    DECLARE nuevo_num_historial VARCHAR(50);
    DECLARE usuario INT;


    -- Asignar valores desde la fila que se está insertando
    SET p_idproducto = NEW.idproducto;
    SET p_codigo_interno = NEW.codigo_interno;
    SET p_codigo_barra = NEW.codigo_barra;
    SET p_codigo_alternativo = NEW.codigo_alternativo;
    SET p_nombre_producto = NEW.nombre_producto;
    SET p_stock_anterior = 0; -- Valor inicial ya que es una nueva inserción
    SET p_salidas = 0; -- Inicialmente, no hay salidas ya que es un nuevo producto
    SET p_stock_actual = NEW.stock;
    SET p_tipo_movimiento = 'NUEVO PRODUCTO';
    SET p_idusuario = NEW.usuario; -- Este valor debería ser dinámico según el usuario actual

    -- Generar el número de historial
    SET numero = (SELECT COALESCE(MAX(idhistorial), 0) + 1 FROM historial);
    SET nuevo_num_historial = CONCAT('HI', LPAD(numero, 8, '0'));

    -- Insertar el nuevo registro en historial
    INSERT INTO historial (
        num_historial, codigo_interno, codigo_barra, codigo_alternativo,
        idproducto, nombre_producto, tipo_movimiento, stock_actual,
        stock_anterior, fecha_movimiento, idusuario
    ) VALUES (
        nuevo_num_historial, p_codigo_interno, p_codigo_barra, p_codigo_alternativo,
        p_idproducto, p_nombre_producto, p_tipo_movimiento, p_stock_actual,
        p_stock_anterior, NOW(), p_idusuario
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insertar_nuevo_producto_inventario` AFTER INSERT ON `producto` FOR EACH ROW BEGIN

    DECLARE p_idproducto INT;

    DECLARE p_stock INT;

    DECLARE p_precio DECIMAL(13,2);

    DECLARE p_costo_total DECIMAL(13,2);

    

	SET p_idproducto = (SELECT MAX(idproducto) FROM producto);

    SET p_stock = (SELECT stock FROM producto WHERE idproducto = p_idproducto);

    SET p_precio = (SELECT precio_compra FROM producto WHERE idproducto = p_idproducto);

    

    SET p_costo_total = p_stock * p_precio;

    

    INSERT INTO inventario (mes_inventario,fecha_apertura,fecha_cierre,saldo_inicial,entradas,salidas,saldo_final,estado,idproducto)

    SELECT DATE_FORMAT(CURDATE(),'%Y-%m'),DATE_FORMAT(CURDATE(),'%Y-%m-01'),LAST_DAY(CURDATE()),p_stock,p_stock,0,p_stock,1,p_idproducto;

	

    INSERT INTO entrada (mes_inventario,fecha_entrada,descripcion_entrada,

    cantidad_entrada,precio_unitario_entrada,costo_total_entrada,idproducto,idcompra)

    VALUES (DATE_FORMAT(CURDATE(),'%Y-%m'),CURDATE(),'INVENTARIO INICIAL',p_stock,p_precio,

    p_costo_total,p_idproducto,NULL);



END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_producto_historial` AFTER UPDATE ON `producto` FOR EACH ROW BEGIN
    -- Declarar variables para los datos del producto
    DECLARE p_codigo_interno VARCHAR(175);
    DECLARE p_codigo_barra VARCHAR(200);
    DECLARE p_codigo_alternativo VARCHAR(200);
    DECLARE p_idproducto INT;
    DECLARE p_nombre_producto VARCHAR(175);
    DECLARE p_tipo_movimiento VARCHAR(255);
    DECLARE p_stock_actual INT;
    DECLARE p_stock_anterior INT;
    DECLARE p_idusuario INT;
    DECLARE p_salidas INT;
    DECLARE numero INT;
    DECLARE nuevo_num_historial VARCHAR(50);
    DECLARE cambios VARCHAR(255);

    -- Obtener información del producto antes y después de la actualización
    SET p_idproducto = NEW.idproducto;
    SET p_codigo_interno = NEW.codigo_interno;
    SET p_codigo_barra = NEW.codigo_barra;
    SET p_codigo_alternativo = NEW.codigo_alternativo;
    SET p_nombre_producto = NEW.nombre_producto;
    SET p_stock_anterior = OLD.stock;
    -- SET p_salidas = (SELECT salidas FROM inventario WHERE idproducto = p_idproducto and mes_inventario = (SELECT MAX(mes_inventario) FROM inventario WHERE idproducto = p_idproducto));
    SET p_stock_actual = NEW.stock; -- Se calcula el stock actual restando las salidas
    SET p_idusuario = NEW.usuario; -- Este valor debería ser dinámico según el usuario actual

    -- Inicializar la lista de cambios como vacía
    SET cambios = '';

    -- Determinar el tipo de movimiento basado en los campos actualizados
    IF NEW.codigo_interno <> OLD.codigo_interno THEN
        SET cambios = CONCAT(cambios, 'CODIGO INTERNO; ');
    END IF;
    IF NEW.codigo_barra <> OLD.codigo_barra THEN
        SET cambios = CONCAT(cambios, 'CODIGO BARRA; ');
    END IF;
    IF NEW.codigo_alternativo <> OLD.codigo_alternativo THEN
        SET cambios = CONCAT(cambios, 'CODIGO ALTERNATIVO; ');
    END IF;
    IF NEW.nombre_producto <> OLD.nombre_producto THEN
        SET cambios = CONCAT(cambios, 'NOMBRE DEL PRODUCTO; ');
    END IF;
    IF NEW.precio_compra <> OLD.precio_compra THEN
        SET cambios = CONCAT(cambios, 'PRECIO DE COMPRA; ');
    END IF;
    IF NEW.precio_venta <> OLD.precio_venta THEN
        SET cambios = CONCAT(cambios, 'PRECIO DE VENTA; ');
    END IF;
    IF NEW.precio_venta1 <> OLD.precio_venta1 THEN
        SET cambios = CONCAT(cambios, 'PRECIO DE VENTA 1; ');
    END IF;
    IF NEW.precio_venta2 <> OLD.precio_venta2 THEN
        SET cambios = CONCAT(cambios, 'PRECIO DE VENTA 2; ');
    END IF;
    IF NEW.precio_venta3 <> OLD.precio_venta3 THEN
        SET cambios = CONCAT(cambios, 'PRECIO DE VENTA 3; ');
    END IF;
    IF NEW.precio_venta_mayoreo <> OLD.precio_venta_mayoreo THEN
        SET cambios = CONCAT(cambios, 'PRECIO DE VENTA MAYOREO; ');
    END IF;
    IF NEW.stock_min <> OLD.stock_min THEN
        SET cambios = CONCAT(cambios, 'STOCK MINIMO; ');
    END IF;
    IF NEW.stock <> OLD.stock THEN
        SET cambios = CONCAT(cambios, 'STOCK; ');
    END IF;
    IF NEW.idcategoria <> OLD.idcategoria THEN
        SET cambios = CONCAT(cambios, 'CATEGORIA; ');
    END IF;
    IF NEW.idmarca <> OLD.idmarca THEN
        SET cambios = CONCAT(cambios, 'MARCA; ');
    END IF;
    IF NEW.idpresentacion <> OLD.idpresentacion THEN
        SET cambios = CONCAT(cambios, 'PRESENTACION; ');
    END IF;
    IF NEW.estado <> OLD.estado THEN
        SET cambios = CONCAT(cambios, 'ESTADO; ');
    END IF;
    IF NEW.exento <> OLD.exento THEN
        SET cambios = CONCAT(cambios, 'EXENTO; ');
    END IF;
    IF NEW.inventariable <> OLD.inventariable THEN
        SET cambios = CONCAT(cambios, 'INVENTARIABLE; ');
    END IF;
    IF NEW.perecedero <> OLD.perecedero THEN
        SET cambios = CONCAT(cambios, 'PERECEDERO; ');
    END IF;
    IF NEW.imagen <> OLD.imagen THEN
        SET cambios = CONCAT(cambios, 'IMAGEN; ');
    END IF;

    -- Si no se detecta ningún cambio, asignar un valor por defecto
    IF cambios = '' THEN
        SET p_tipo_movimiento = 'ACTUALIZA PRODUCTO';
    ELSE
        -- Eliminar el último punto y coma y espacio, y agregar "ACTUALIZA" al principio
        SET cambios = LEFT(cambios, LENGTH(cambios) - 2);
        SET p_tipo_movimiento = CONCAT('ACTUALIZA: ', cambios);
    END IF;

    -- Generar el número de historial
    SET numero = (SELECT COALESCE(MAX(idhistorial), 0) + 1 FROM historial);
    SET nuevo_num_historial = CONCAT('HI', LPAD(numero, 8, '0'));

    -- Insertar el nuevo registro en historial
    INSERT INTO historial (
        num_historial, codigo_interno, codigo_barra, codigo_alternativo,
        idproducto, nombre_producto, tipo_movimiento, stock_actual,
        stock_anterior, fecha_movimiento, idusuario
    ) VALUES (
        nuevo_num_historial, p_codigo_interno, p_codigo_barra, p_codigo_alternativo,
        p_idproducto, p_nombre_producto, p_tipo_movimiento, p_stock_actual,
        p_stock_anterior, NOW(), p_idusuario
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `producto_proveedor`
--

CREATE TABLE `producto_proveedor` (
  `idproveedor` int(11) NOT NULL,
  `idproducto` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `proveedor`
--

CREATE TABLE `proveedor` (
  `idproveedor` int(11) NOT NULL,
  `codigo_proveedor` varchar(175) DEFAULT NULL,
  `nombre_proveedor` varchar(175) NOT NULL,
  `numero_telefono` varchar(70) NOT NULL,
  `numero_nit` varchar(70) NOT NULL,
  `numero_nrc` varchar(70) NOT NULL,
  `nombre_contacto` varchar(150) DEFAULT NULL,
  `telefono_contacto` varchar(70) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1,
  `Correo` varchar(50) NOT NULL,
  `Direccion` varchar(250) NOT NULL,
  `Comentario` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `proveedor`
--

INSERT INTO `proveedor` (`idproveedor`, `codigo_proveedor`, `nombre_proveedor`, `numero_telefono`, `numero_nit`, `numero_nrc`, `nombre_contacto`, `telefono_contacto`, `estado`, `Correo`, `Direccion`, `Comentario`) VALUES
(1, 'PROV00000001', 'DELL', '123', '', '123', 'ABEL DOMINGUEZ', '', 1, 'DELL@GMAIL.COM', 'PANAMA', '');

--
-- Triggers `proveedor`
--
DELIMITER $$
CREATE TRIGGER `generar_codigo_proveedor` BEFORE INSERT ON `proveedor` FOR EACH ROW BEGIN

    

        DECLARE numero INT;

        

        SET numero = (SELECT max(idproveedor) FROM proveedor);

 

		IF numero IS NULL then

		  set numero=1;

        SET NEW.codigo_proveedor ='PROV00000001';



		ELSEIF numero >= 1 and numero < 9 then

			set numero=numero+1;

		SET NEW.codigo_proveedor =(select concat('PROV0000000',CAST(numero AS CHAR)));

        

		ELSEIF numero >=9 and numero<=99 then

			set numero=numero+1;

		SET NEW.codigo_proveedor =(select concat('PROV000000',CAST(numero AS CHAR)));

            

		ELSEIF numero>=99 and numero<=999 then

			set numero=numero+1;

		SET NEW.codigo_proveedor =(select concat('PROV00000',CAST(numero AS CHAR)));

             

		ELSEIF numero>=999 and numero<=9999 then

		   set numero=numero+1;

		SET NEW.codigo_proveedor =(select concat('PROV0000',CAST(numero AS CHAR)));

           

		ELSEIF numero>=9999 and numero<=99999 then

			set numero=numero+1;

		SET NEW.codigo_proveedor =(select concat('PROV000',CAST(numero AS CHAR)));

             



		ELSEIF numero>=99999 and numero<=999999 then

			set numero=numero+1;

		SET NEW.codigo_proveedor =(select concat('PROV00',CAST(numero AS CHAR)));

            



		ELSEIF numero>=999999 and numero<=9999999 then

			set numero=numero+1;

		SET NEW.codigo_proveedor =(select concat('PROV0',CAST(numero AS CHAR)));

            

        ELSEIF numero>=9999999  then 			set numero=numero+1;

		SET NEW.codigo_proveedor =(select concat('PROV',CAST(numero AS CHAR)));

            

		END IF;

        

    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `proveedor_precio`
--

CREATE TABLE `proveedor_precio` (
  `idproveedor` int(11) NOT NULL,
  `idproducto` int(11) NOT NULL,
  `fecha_precio` date NOT NULL,
  `precio_compra` decimal(13,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `proveedor_precio`
--

INSERT INTO `proveedor_precio` (`idproveedor`, `idproducto`, `fecha_precio`, `precio_compra`) VALUES
(1, 1, '2024-07-04', 20.00),
(1, 2, '2024-07-05', 20.00),
(1, 3, '2024-11-01', 49.99);

-- --------------------------------------------------------

--
-- Table structure for table `salida`
--

CREATE TABLE `salida` (
  `idsalida` int(11) NOT NULL,
  `mes_inventario` varchar(7) NOT NULL,
  `fecha_salida` date NOT NULL,
  `descripcion_salida` varchar(150) NOT NULL,
  `cantidad_salida` int(11) NOT NULL,
  `precio_unitario_salida` decimal(13,2) NOT NULL,
  `costo_total_salida` decimal(13,2) NOT NULL,
  `idproducto` int(11) NOT NULL,
  `idventa` int(11) DEFAULT NULL,
  `idapartado` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `salida`
--

INSERT INTO `salida` (`idsalida`, `mes_inventario`, `fecha_salida`, `descripcion_salida`, `cantidad_salida`, `precio_unitario_salida`, `costo_total_salida`, `idproducto`, `idventa`, `idapartado`) VALUES
(1, '2024-07', '2024-07-04', 'POR VENTA FACTURA # 1', 1, 20.00, 20.00, 1, 1, NULL),
(2, '2024-07', '2024-07-04', 'POR VENTA TICKET # 1', 1, 20.00, 20.00, 1, 2, NULL),
(3, '2024-07', '2024-07-04', 'POR VENTA FACTURA # 2', 1, 20.00, 20.00, 2, 3, NULL),
(4, '2024-07', '2024-07-06', 'POR VENTA TICKET # 2', 1, 20.00, 20.00, 1, 4, NULL),
(5, '2024-07', '2024-07-06', 'POR VENTA TICKET # 3', 1, 20.00, 20.00, 2, 5, NULL),
(6, '2024-07', '2024-07-06', 'POR VENTA TICKET # 4', 2, 20.00, 40.00, 2, 6, NULL),
(7, '2024-07', '2024-07-06', 'POR VENTA TICKET # 5', 3, 20.00, 60.00, 2, 7, NULL),
(8, '2024-07', '2024-07-06', 'POR VENTA TICKET # 6', 2, 20.00, 40.00, 2, 8, NULL),
(9, '2024-07', '2024-07-07', 'POR VENTA TICKET # 7', 3, 20.00, 60.00, 1, 9, NULL),
(10, '2024-07', '2024-07-08', 'POR VENTA TICKET # 8', 1, 20.00, 20.00, 2, 10, NULL),
(11, '2024-07', '2024-07-08', 'POR VENTA TICKET # 9', 1, 20.00, 20.00, 1, 11, NULL),
(12, '2024-07', '2024-07-08', 'POR VENTA TICKET # 10', 2, 20.00, 40.00, 2, 12, NULL),
(13, '2024-07', '2024-07-08', 'POR VENTA TICKET # 11', 3, 20.00, 60.00, 2, 13, NULL),
(14, '2024-07', '2024-07-16', 'POR VENTA TICKET # 12', 1, 20.00, 20.00, 1, 14, NULL),
(15, '2024-07', '2024-07-16', 'POR VENTA TICKET # 13', 1, 20.00, 20.00, 1, 15, NULL),
(16, '2024-07', '2024-07-16', 'POR VENTA TICKET # 13', 1, 20.00, 20.00, 2, 15, NULL),
(17, '2024-07', '2024-07-16', 'POR VENTA TICKET # 14', 1, 20.00, 20.00, 1, 16, NULL),
(18, '2024-07', '2024-07-16', 'POR VENTA TICKET # 14', 1, 20.00, 20.00, 2, 16, NULL),
(19, '2024-07', '2024-07-22', 'POR VENTA TICKET # 15', 5, 20.00, 100.00, 2, 17, NULL),
(20, '2024-07', '2024-07-24', 'POR VENTA TICKET # 16', 1, 20.00, 20.00, 1, 18, NULL),
(21, '2024-07', '2024-07-24', 'POR VENTA TICKET # 17', 2, 20.00, 40.00, 2, 19, NULL),
(22, '2024-07', '2024-07-24', 'POR VENTA TICKET # 18', 2, 20.00, 40.00, 1, 20, NULL),
(23, '2024-07', '2024-07-25', 'POR VENTA TICKET # 19', 2, 20.00, 40.00, 1, 21, NULL),
(24, '2024-07', '2024-07-25', 'POR VENTA TICKET # 20', 2, 20.00, 40.00, 1, 22, NULL),
(25, '2024-07', '2024-07-25', 'POR VENTA TICKET # 21', 2, 20.00, 40.00, 1, 23, NULL),
(26, '2024-07', '2024-07-25', 'POR VENTA TICKET # 22', 2, 20.00, 40.00, 1, 24, NULL),
(27, '2024-07', '2024-07-25', 'POR VENTA TICKET # 23', 1, 20.00, 20.00, 1, 25, NULL),
(28, '2024-07', '2024-07-25', 'POR VENTA TICKET # 24', 1, 20.00, 20.00, 2, 26, NULL),
(29, '2024-07', '2024-07-25', 'POR VENTA TICKET # 25', 2, 20.00, 40.00, 1, 27, NULL),
(55, '2024-07', '2024-07-26', 'POR VENTA TICKET # 27', 1, 20.00, 20.00, 1, 29, NULL),
(56, '2024-07', '2024-07-26', 'POR VENTA TICKET # 27', 1, 20.00, 20.00, 2, 29, NULL),
(57, '2024-07', '2024-07-26', 'POR VENTA TICKET # 28', 1, 20.00, 20.00, 1, 30, NULL),
(58, '2024-07', '2024-07-26', 'POR VENTA TICKET # 28', 1, 20.00, 20.00, 2, 30, NULL),
(59, '2024-07', '2024-07-26', 'POR VENTA TICKET # 29', 1, 20.00, 20.00, 1, 31, NULL),
(60, '2024-07', '2024-07-26', 'POR VENTA TICKET # 29', 1, 20.00, 20.00, 2, 31, NULL),
(61, '2024-07', '2024-07-26', 'POR VENTA TICKET # 30', 1, 20.00, 20.00, 1, 32, NULL),
(62, '2024-07', '2024-07-26', 'POR VENTA TICKET # 30', 1, 20.00, 20.00, 2, 32, NULL),
(63, '2024-07', '2024-07-26', 'POR VENTA TICKET # 31', 1, 20.00, 20.00, 1, 33, NULL),
(64, '2024-07', '2024-07-26', 'POR VENTA TICKET # 31', 1, 20.00, 20.00, 2, 33, NULL),
(65, '2024-07', '2024-07-26', 'POR VENTA TICKET # 32', 1, 20.00, 20.00, 1, 34, NULL),
(66, '2024-07', '2024-07-26', 'POR VENTA TICKET # 32', 1, 20.00, 20.00, 2, 34, NULL),
(67, '2024-07', '2024-07-26', 'POR VENTA TICKET # 33', 1, 20.00, 20.00, 1, 35, NULL),
(68, '2024-07', '2024-07-26', 'POR VENTA TICKET # 33', 1, 20.00, 20.00, 2, 35, NULL),
(69, '2024-07', '2024-07-26', 'POR VENTA TICKET # 34', 1, 20.00, 20.00, 1, 36, NULL),
(70, '2024-07', '2024-07-26', 'POR VENTA TICKET # 34', 1, 20.00, 20.00, 2, 36, NULL),
(71, '2024-07', '2024-07-26', 'POR VENTA TICKET # 35', 1, 20.00, 20.00, 1, 37, NULL),
(72, '2024-07', '2024-07-26', 'POR VENTA TICKET # 35', 1, 20.00, 20.00, 2, 37, NULL),
(73, '2024-07', '2024-07-26', 'POR VENTA TICKET # 36', 1, 20.00, 20.00, 1, 38, NULL),
(74, '2024-07', '2024-07-26', 'POR VENTA TICKET # 36', 1, 20.00, 20.00, 2, 38, NULL),
(75, '2024-07', '2024-07-26', 'POR VENTA TICKET # 37', 1, 20.00, 20.00, 1, 39, NULL),
(76, '2024-07', '2024-07-26', 'POR VENTA TICKET # 37', 1, 20.00, 20.00, 2, 39, NULL),
(77, '2024-07', '2024-07-26', 'POR VENTA TICKET # 38', 1, 20.00, 20.00, 1, 40, NULL),
(78, '2024-07', '2024-07-26', 'POR VENTA TICKET # 38', 1, 20.00, 20.00, 2, 40, NULL),
(79, '2024-07', '2024-07-26', 'POR VENTA TICKET # 39', 1, 20.00, 20.00, 1, 41, NULL),
(80, '2024-07', '2024-07-26', 'POR VENTA TICKET # 39', 1, 20.00, 20.00, 2, 41, NULL),
(81, '2024-07', '2024-07-26', 'POR VENTA TICKET # 40', 1, 20.00, 20.00, 1, 42, NULL),
(82, '2024-07', '2024-07-26', 'POR VENTA TICKET # 40', 1, 20.00, 20.00, 2, 42, NULL),
(83, '2024-10', '2024-10-15', 'POR VENTA TICKET # 41', 1, 20.00, 20.00, 1, 43, NULL),
(84, '2024-10', '2024-10-29', 'POR VENTA TICKET # 42', 2, 20.00, 40.00, 1, 44, NULL),
(85, '2024-10', '2024-10-29', 'POR VENTA TICKET # 42', 2, 20.00, 40.00, 2, 44, NULL),
(86, '2024-11', '2024-11-01', 'POR VENTA TICKET # 43', 1, 20.00, 20.00, 1, 45, NULL),
(87, '2024-11', '2024-11-01', 'POR VENTA TICKET # 43', 2, 20.00, 40.00, 2, 45, NULL),
(88, '2024-11', '2024-11-01', 'POR VENTA TICKET # 44', 10, 49.99, 499.90, 3, 46, NULL),
(89, '2024-11', '2024-11-01', 'POR VENTA TICKET # 45', 10, 49.99, 499.90, 3, 47, NULL),
(90, '2024-11', '2024-11-06', 'POR VENTA TICKET # 46', 2, 20.00, 40.00, 1, 48, NULL),
(91, '2024-11', '2024-11-06', 'POR VENTA TICKET # 46', 2, 20.00, 40.00, 2, 48, NULL),
(92, '2024-11', '2024-11-06', 'POR VENTA TICKET # 47', 2, 20.00, 40.00, 1, 49, NULL),
(93, '2024-11', '2024-11-06', 'POR VENTA TICKET # 47', 2, 20.00, 40.00, 2, 49, NULL),
(94, '2024-11', '2024-11-06', 'POR VENTA TICKET # 48', 2, 20.00, 40.00, 1, 50, NULL),
(95, '2024-11', '2024-11-06', 'POR VENTA TICKET # 48', 2, 20.00, 40.00, 2, 50, NULL),
(96, '2024-11', '2024-11-08', 'POR VENTA TICKET # 49', 2, 20.00, 40.00, 1, 51, NULL),
(97, '2024-11', '2024-11-08', 'POR VENTA TICKET # 50', 2, 20.00, 40.00, 1, 52, NULL),
(98, '2024-11', '2024-11-12', 'POR VENTA TICKET # 51', 2, 20.00, 40.00, 1, 53, NULL),
(99, '2024-11', '2024-11-12', 'POR VENTA TICKET # 52', 1, 20.00, 20.00, 1, 54, NULL),
(100, '2024-11', '2024-11-15', 'POR VENTA TICKET # 53', 1, 35.00, 35.00, 1, 55, NULL),
(101, '2024-11', '2024-11-15', 'POR VENTA TICKET # 59', 1, 20.00, 20.00, 1, 61, NULL),
(102, '2024-11', '2024-11-15', 'POR VENTA TICKET # 60', 2, 20.00, 40.00, 2, 62, NULL),
(103, '2024-11', '2024-11-15', 'POR VENTA TICKET # 61', 2, 20.00, 40.00, 2, 63, NULL),
(104, '2024-11', '2024-11-15', 'POR VENTA TICKET # 62', 2, 20.00, 40.00, 1, 64, NULL),
(105, '2024-11', '2024-11-15', 'POR VENTA TICKET # 62', 1, 20.00, 20.00, 2, 64, NULL),
(106, '2024-11', '2024-11-15', 'POR VENTA TICKET # 63', 2, 20.00, 40.00, 1, 65, NULL),
(107, '2024-11', '2024-11-15', 'POR VENTA TICKET # 63', 1, 20.00, 20.00, 2, 65, NULL),
(108, '2024-11', '2024-11-15', 'POR VENTA TICKET # 64', 2, 20.00, 40.00, 1, 66, NULL),
(109, '2024-11', '2024-11-15', 'POR VENTA TICKET # 64', 1, 20.00, 20.00, 2, 66, NULL),
(110, '2024-11', '2024-11-15', 'POR VENTA TICKET # 65', 2, 20.00, 40.00, 1, 67, NULL),
(111, '2024-11', '2024-11-15', 'POR VENTA TICKET # 65', 1, 20.00, 20.00, 2, 67, NULL),
(112, '2024-11', '2024-11-16', 'POR VENTA TICKET # 66', 2, 20.00, 40.00, 1, 68, NULL),
(113, '2024-11', '2024-11-16', 'POR VENTA TICKET # 66', 1, 20.00, 20.00, 2, 68, NULL),
(114, '2024-11', '2024-11-16', 'POR VENTA TICKET # 67', 2, 20.00, 40.00, 1, 69, NULL),
(115, '2024-11', '2024-11-16', 'POR VENTA TICKET # 67', 1, 20.00, 20.00, 2, 69, NULL),
(116, '2024-11', '2024-11-16', 'POR VENTA TICKET # 68', 2, 20.00, 40.00, 1, 70, NULL),
(117, '2024-11', '2024-11-16', 'POR VENTA TICKET # 68', 1, 20.00, 20.00, 2, 70, NULL),
(118, '2024-11', '2024-11-16', 'POR VENTA TICKET # 69', 3, 20.00, 60.00, 1, 71, NULL),
(119, '2024-11', '2024-11-16', 'POR VENTA TICKET # 69', 2, 20.00, 40.00, 2, 71, NULL),
(120, '2024-11', '2024-11-16', 'POR VENTA TICKET # 70', 3, 20.00, 60.00, 1, 72, NULL),
(121, '2024-11', '2024-11-16', 'POR VENTA TICKET # 70', 2, 20.00, 40.00, 2, 72, NULL),
(122, '2024-11', '2024-11-19', 'POR VENTA TICKET # 71', 1, 20.00, 20.00, 1, 73, NULL),
(123, '2024-11', '2024-11-19', 'POR VENTA TICKET # 72', 1, 20.00, 20.00, 1, 74, NULL),
(124, '2024-11', '2024-11-20', 'POR VENTA TICKET # 73', 1, 20.00, 20.00, 1, 75, NULL),
(125, '2024-11', '2024-11-20', 'POR VENTA TICKET # 74', 5, 20.00, 100.00, 2, 76, NULL),
(126, '2024-11', '2024-11-20', 'POR VENTA TICKET # 75', 5, 20.00, 100.00, 1, 77, NULL),
(127, '2024-11', '2024-11-20', 'POR VENTA TICKET # 76', 1, 20.00, 20.00, 1, 78, NULL),
(128, '2024-11', '2024-11-20', 'POR VENTA TICKET # 77', 1, 20.00, 20.00, 1, 79, NULL),
(129, '2024-11', '2024-11-20', 'POR VENTA TICKET # 78', 1, 49.99, 49.99, 3, 80, NULL),
(130, '2024-12', '2024-12-10', 'POR VENTA TICKET # 79', 2, 20.00, 40.00, 1, 81, NULL),
(131, '2024-12', '2024-12-10', 'POR VENTA TICKET # 79', 2, 20.00, 40.00, 2, 81, NULL),
(132, '2024-12', '2024-12-10', 'POR VENTA TICKET # 80', 2, 20.00, 40.00, 1, 82, NULL),
(133, '2024-12', '2024-12-10', 'POR VENTA TICKET # 80', 2, 20.00, 40.00, 2, 82, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `tecnico`
--

CREATE TABLE `tecnico` (
  `idtecnico` int(11) NOT NULL,
  `tecnico` varchar(150) NOT NULL,
  `telefono` varchar(70) DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tecnico`
--

INSERT INTO `tecnico` (`idtecnico`, `tecnico`, `telefono`, `estado`) VALUES
(1, 'TECNICOS PANAMA', '965965956', 1);

-- --------------------------------------------------------

--
-- Table structure for table `tiraje_comprobante`
--

CREATE TABLE `tiraje_comprobante` (
  `idtiraje` int(11) NOT NULL,
  `fecha_resolucion` datetime NOT NULL,
  `numero_resolucion` varchar(100) DEFAULT NULL,
  `serie` varchar(175) NOT NULL,
  `desde` int(11) NOT NULL,
  `hasta` int(11) NOT NULL,
  `idcomprobante` int(11) NOT NULL,
  `disponibles` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tiraje_comprobante`
--

INSERT INTO `tiraje_comprobante` (`idtiraje`, `fecha_resolucion`, `numero_resolucion`, `serie`, `desde`, `hasta`, `idcomprobante`, `disponibles`) VALUES
(1, '2024-07-04 10:52:59', '1', '1', 1, 1000, 1, 920),
(2, '2024-07-04 10:52:59', '2', '2', 1, 1000, 2, 998),
(3, '2024-07-04 10:52:59', '3', '3', 1, 1000, 3, 1000);

-- --------------------------------------------------------

--
-- Table structure for table `usuario`
--

CREATE TABLE `usuario` (
  `idusuario` int(11) NOT NULL,
  `usuario` varchar(8) NOT NULL,
  `contrasena` varchar(180) NOT NULL,
  `tipo_usuario` tinyint(1) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1,
  `idempleado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `usuario`
--

INSERT INTO `usuario` (`idusuario`, `usuario`, `contrasena`, `tipo_usuario`, `estado`, `idempleado`) VALUES
(1, 'admin', '$2y$10$R7ocBTAQQjPViu3xoReZ0uL.ROw6CsnQdg0ZdaAJRO4puGdYp058S', 1, 1, 1),
(2, 'vendedor', '$2y$10$R7ocBTAQQjPViu3xoReZ0uL.ROw6CsnQdg0ZdaAJRO4puGdYp058S', 2, 1, 2),
(3, 'cajero', '$2y$10$R7ocBTAQQjPViu3xoReZ0uL.ROw6CsnQdg0ZdaAJRO4puGdYp058S', 3, 1, 3),
(4, 'tecnico', '$2y$10$R7ocBTAQQjPViu3xoReZ0uL.ROw6CsnQdg0ZdaAJRO4puGdYp058S', 4, 1, 4);

-- --------------------------------------------------------

--
-- Table structure for table `venta`
--

CREATE TABLE `venta` (
  `idventa` int(11) NOT NULL,
  `numero_venta` varchar(175) DEFAULT NULL,
  `fecha_venta` datetime NOT NULL,
  `tipo_pago` varchar(75) NOT NULL,
  `numero_comprobante` int(11) NOT NULL,
  `tipo_comprobante` tinyint(1) NOT NULL,
  `sumas` decimal(13,2) NOT NULL,
  `iva` decimal(13,2) NOT NULL,
  `exento` decimal(13,2) NOT NULL,
  `retenido` decimal(13,2) NOT NULL,
  `descuento` decimal(13,2) NOT NULL,
  `total` decimal(13,2) NOT NULL,
  `sonletras` varchar(150) NOT NULL,
  `pago_efectivo` decimal(13,2) NOT NULL DEFAULT 0.00,
  `pago_tarjeta` decimal(13,2) NOT NULL DEFAULT 0.00,
  `numero_tarjeta` varchar(16) DEFAULT NULL,
  `tarjeta_habiente` varchar(90) DEFAULT NULL,
  `cambio` decimal(13,2) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1,
  `idcliente` int(11) DEFAULT NULL,
  `idusuario` int(11) NOT NULL,
  `facturado` int(11) DEFAULT NULL,
  `idUserCajero` int(11) DEFAULT NULL,
  `fecha_factura` datetime DEFAULT NULL,
  `tipoVenta` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `venta`
--

INSERT INTO `venta` (`idventa`, `numero_venta`, `fecha_venta`, `tipo_pago`, `numero_comprobante`, `tipo_comprobante`, `sumas`, `iva`, `exento`, `retenido`, `descuento`, `total`, `sonletras`, `pago_efectivo`, `pago_tarjeta`, `numero_tarjeta`, `tarjeta_habiente`, `cambio`, `estado`, `idcliente`, `idusuario`, `facturado`, `idUserCajero`, `fecha_factura`, `tipoVenta`) VALUES
(1, 'V00000001', '2024-07-04 11:18:37', 'EFECTIVO', 1, 1, 37.38, 2.62, 0.00, 0.00, 0.00, 40.00, 'Cientos cuarenta 00/100 USD', 40.00, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 3, '2024-07-08 11:32:28', NULL),
(2, 'V00000002', '2024-07-04 11:23:07', 'EFECTIVO', 1, 1, 40.00, 2.80, 40.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 42.80, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 3, '2024-07-08 11:04:14', NULL),
(3, 'V00000003', '2024-07-04 11:55:50', 'EFECTIVO', 2, 1, 30.00, 2.10, 30.00, 0.00, 0.00, 32.10, 'Cientos treinta y dos 10/100 USD', 32.10, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 3, '2024-07-08 10:44:31', NULL),
(4, 'V00000004', '2024-07-06 20:01:06', 'EFECTIVO', 2, 1, 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 42.80, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 3, '2024-07-08 10:39:45', NULL),
(5, 'V00000005', '2024-07-06 20:05:34', 'EFECTIVO', 3, 1, 30.00, 0.00, 2.10, 0.00, 0.00, 30.00, 'Cientos treinta 00/100 USD', 30.00, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, NULL, '2024-07-08 10:34:48', NULL),
(6, 'V00000006', '2024-07-06 20:29:37', 'EFECTIVO', 4, 1, 60.00, 0.00, 4.20, 0.00, 0.00, 60.00, 'Cientos sesenta 00/100 USD', 60.00, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, NULL, '2024-07-08 10:24:13', NULL),
(7, 'V00000007', '2024-07-06 20:35:13', 'EFECTIVO', 5, 1, 90.00, 0.00, 6.30, 0.00, 0.00, 90.00, 'Cientos noventa 00/100 USD', 90.00, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, NULL, '2024-07-08 10:13:22', NULL),
(8, 'V00000008', '2024-07-06 21:24:36', 'EFECTIVO', 6, 1, 60.00, 0.00, 4.20, 0.00, 0.00, 60.00, 'Cientos sesenta 00/100 USD', 60.00, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, NULL, '2024-07-07 03:03:21', NULL),
(9, 'V00000009', '2024-07-07 00:21:11', 'EFECTIVO', 7, 1, 120.00, 8.40, 0.00, 0.00, 0.00, 128.40, 'Ciento veintiocho 40/100 USD', 128.40, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, NULL, '2024-07-07 02:49:44', NULL),
(10, 'V00000010', '2024-07-08 11:35:04', 'EFECTIVO', 8, 1, 30.00, 0.00, 2.10, 0.00, 0.00, 30.00, 'Cientos treinta 00/100 USD', 30.00, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 3, '2024-07-08 11:51:19', NULL),
(11, 'V00000011', '2024-07-08 11:35:17', 'EFECTIVO', 9, 1, 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 0.00, 0.00, '', '', 0.00, 1, 1, 1, NULL, NULL, NULL, NULL),
(12, 'V00000012', '2024-07-08 11:35:30', 'EFECTIVO', 10, 1, 60.00, 0.00, 4.20, 0.00, 0.00, 60.00, 'Cientos sesenta 00/100 USD', 50.00, 0.00, '0.00', '0.00', -10.00, 1, 1, 1, 1, 3, '2024-11-08 08:45:38', 1),
(13, 'V00000013', '2024-07-08 11:35:40', 'EFECTIVO', 11, 1, 90.00, 0.00, 6.30, 0.00, 0.00, 90.00, 'Cientos noventa 00/100 USD', 90.00, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 3, '2024-07-08 11:50:56', NULL),
(14, 'V00000014', '2024-07-16 10:06:27', 'EFECTIVO', 12, 2, 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 43.00, 0.00, '0.00', '0.00', 0.20, 1, 1, 1, 1, 1, '2024-11-06 15:42:05', 1),
(15, 'V00000015', '2024-07-16 10:56:10', '1', 13, 2, 70.00, 2.80, 2.10, 0.00, 0.00, 72.80, 'Cientos setenta y dos 80/100 USD', 73.00, 0.00, '0.00', '0.00', 0.20, 1, 1, 1, 1, 0, '2024-10-31 11:01:45', 0),
(16, 'V00000016', '2024-07-16 11:00:25', 'EFECTIVO', 14, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 0.00, 0.00, '', '', 0.00, 1, 1, 1, 1, NULL, NULL, NULL),
(17, 'V00000017', '2024-07-22 12:00:19', 'EFECTIVO', 15, 1, 150.00, 0.00, 10.50, 0.00, 0.00, 150.00, 'Ciento cincuenta 00/100 USD', 140.00, 0.00, '0.00', '0.00', -10.00, 1, 1, 1, 1, 1, '2024-11-06 15:37:15', 1),
(18, 'V00000018', '2024-07-24 08:59:55', 'EFECTIVO', 16, 1, 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 0.00, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 1, '2024-07-24 09:26:09', NULL),
(19, 'V00000019', '2024-07-24 11:07:29', 'EFECTIVO', 17, 1, 60.00, 0.00, 4.20, 0.00, 0.00, 60.00, 'Cientos sesenta 00/100 USD', 0.00, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 1, '2024-07-24 11:07:52', 1),
(20, 'V00000020', '2024-07-24 11:15:03', 'EFECTIVO', 18, 1, 80.00, 5.60, 0.00, 0.00, 0.00, 85.60, 'Cientos ochenta y cinco 60/100 USD', 0.00, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 1, '2024-07-24 11:37:30', 2),
(21, 'V00000021', '2024-07-25 12:13:54', 'EFECTIVO', 19, 1, 80.00, 5.60, 0.00, 0.00, 0.00, 85.60, 'Cientos ochenta y cinco 60/100 USD', 87.00, 0.00, '0.00', '0.00', 1.40, 1, 1, 1, 1, 1, '2024-11-06 15:41:53', 1),
(22, 'V00000022', '2024-07-25 12:27:29', 'EFECTIVO', 20, 2, 80.00, 5.60, 0.00, 0.00, 0.00, 85.60, 'Cientos ochenta y cinco 60/100 USD', 85.00, 0.00, '0.00', '0.00', -0.60, 1, 1, 1, 1, 1, '2024-11-06 15:18:43', 1),
(23, 'V00000023', '2024-07-25 12:35:00', 'EFECTIVO', 21, 1, 80.00, 5.60, 0.00, 0.00, 0.00, 85.60, 'Cientos ochenta y cinco 60/100 USD', 86.00, 0.00, '0.00', '0.00', 0.40, 1, 1, 1, 1, 1, '2024-11-01 11:51:30', 1),
(24, 'V00000024', '2024-07-25 12:59:32', 'EFECTIVO', 22, 1, 80.00, 5.60, 0.00, 0.00, 0.00, 85.60, 'Cientos ochenta y cinco 60/100 USD', 86.00, 0.00, '0.00', '0.00', 0.40, 1, 1, 1, 1, 1, '2024-10-31 09:17:25', 1),
(25, 'V00000025', '2024-07-25 13:57:56', 'EFECTIVO', 23, 1, 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 43.00, 0.00, '0.00', '0.00', 0.20, 1, 1, 1, 1, 1, '2024-10-31 09:15:39', 1),
(26, 'V00000026', '2024-07-25 14:52:16', '1', 24, 1, 30.00, 0.00, 2.10, 0.00, 0.00, 30.00, 'Cientos treinta 00/100 USD', 30.00, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 0, '2024-10-30 15:31:09', 0),
(27, 'V00000027', '2024-07-25 15:03:53', 'EFECTIVO', 25, 1, 80.00, 5.60, 0.00, 0.00, 0.00, 85.60, 'Cientos ochenta y cinco 60/100 USD', 85.60, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 1, '2024-07-25 15:07:15', 1),
(29, 'V00000029', '2024-07-26 11:31:34', 'EFECTIVO', 27, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 71.00, 0.00, '0.00', '0.00', 0.30, 1, 1, 1, 1, 1, '2024-10-30 14:59:43', 1),
(30, 'V00000030', '2024-07-26 11:34:10', 'EFECTIVO', 28, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 71.00, 0.00, '0.00', '0.00', 0.30, 1, 1, 1, 1, 1, '2024-10-30 14:54:17', 1),
(31, 'V00000031', '2024-07-26 11:34:33', 'EFECTIVO', 29, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 75.00, 0.00, '0.00', '0.00', 4.30, 1, 1, 1, 1, 1, '2024-10-30 11:10:48', 1),
(32, 'V00000032', '2024-07-26 11:38:52', '1', 30, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 75.00, 0.00, '0.00', '0.00', 4.30, 1, 1, 1, 1, 0, '2024-10-30 09:19:30', 0),
(33, 'V00000033', '2024-07-26 11:50:01', 'EFECTIVO', 31, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 80.00, 0.00, '0.00', '0.00', 9.30, 1, 1, 1, 1, 1, '2024-10-30 09:05:03', 1),
(34, 'V00000034', '2024-07-26 12:19:16', 'EFECTIVO', 32, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 80.00, 0.00, '0.00', '0.00', 9.30, 1, 1, 1, 1, 1, '2024-10-29 15:58:52', 1),
(35, 'V00000035', '2024-07-26 12:43:17', 'EFECTIVO', 33, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 80.00, 0.00, '0.00', '0.00', 9.30, 1, 1, 1, 1, 1, '2024-10-29 15:34:48', 1),
(36, 'V00000036', '2024-07-26 12:47:31', 'EFECTIVO', 34, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 80.00, 0.00, '0.00', '0.00', 9.30, 1, 1, 1, 1, 1, '2024-10-29 14:37:36', 1),
(37, 'V00000037', '2024-07-26 12:50:05', 'EFECTIVO', 35, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 70.70, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 1, '2024-10-29 14:27:28', 1),
(38, 'V00000038', '2024-07-26 12:50:31', 'EFECTIVO', 36, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 70.60, 0.00, '0.00', '0.00', -0.10, 1, 1, 1, 1, 1, '2024-10-29 14:26:55', 1),
(39, 'V00000039', '2024-07-26 12:50:53', 'EFECTIVO', 37, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 70.70, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 1, '2024-10-29 12:57:58', 1),
(40, 'V00000040', '2024-07-26 12:53:41', 'EFECTIVO', 38, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 75.00, 0.00, '0.00', '0.00', 4.30, 1, 1, 1, 1, 1, '2024-10-15 08:24:59', 1),
(41, 'V00000041', '2024-07-26 12:58:38', 'EFECTIVO', 39, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 100.00, 0.00, '0.00', '0.00', 29.30, 1, 1, 1, 1, 3, '2024-10-14 13:00:29', 1),
(42, 'V00000042', '2024-07-26 15:01:24', 'EFECTIVO', 40, 1, 70.00, 2.80, 2.10, 0.00, 2.10, 70.70, 'Cientos setenta 70/100 USD', 70.70, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 1, '2024-07-26 15:14:20', 1),
(43, 'V00000043', '2024-10-15 08:23:42', 'EFECTIVO', 41, 1, 45.00, 3.15, 0.00, 0.00, 0.00, 48.15, 'Cientos cuarenta y ocho 15/100 USD', 50.00, 0.00, '0.00', '0.00', 1.85, 1, 1, 1, 1, 1, '2024-10-15 08:24:26', 1),
(44, 'V00000044', '2024-10-29 12:41:22', 'EFECTIVO', 42, 1, 151.90, 6.29, 4.34, 0.00, 2.10, 158.19, 'Ciento cincuenta y ocho 19/100 USD', 160.00, 0.00, '0.00', '0.00', 1.81, 1, 1, 1, 1, 1, '2024-10-29 12:43:14', 1),
(45, 'V00000045', '2024-11-01 10:07:32', 'EFECTIVO', 43, 2, 99.95, 2.80, 4.20, 0.00, 0.05, 102.75, 'Ciento dos 75/100 USD', 103.00, 0.00, '0.00', '0.00', 0.25, 1, 1, 1, 1, 1, '2024-11-01 10:09:08', 1),
(46, 'V00000046', '2024-11-01 10:29:56', 'EFECTIVO', 44, 1, 300.00, 21.00, 0.00, 0.00, 0.00, 321.00, 'Trescientos veintiuno 00/100 USD', 322.00, 0.00, '0.00', '0.00', 1.00, 1, 1, 1, 1, 1, '2024-11-01 10:30:23', 1),
(47, 'V00000047', '2024-11-01 10:31:33', 'EFECTIVO', 45, 1, 300.00, 21.00, 0.00, 0.00, 0.00, 321.00, 'Trescientos veintiuno 00/100 USD', 321.00, 0.00, '0.00', '0.00', 0.00, 1, 1, 1, 1, 1, '2024-11-01 10:31:46', 1),
(48, 'V00000048', '2024-11-06 15:40:24', 'EFECTIVO', 46, 1, 160.00, 6.30, 4.90, 0.00, 0.00, 166.30, 'Ciento sesenta y seis 30/100 USD', 167.00, 0.00, '0.00', '0.00', 0.70, 1, 1, 1, 1, 1, '2024-11-06 15:40:45', 1),
(49, 'V00000049', '2024-11-06 15:49:00', 'EFECTIVO', 47, 1, 159.80, 6.29, 4.89, 0.00, 0.20, 166.09, 'Ciento sesenta y seis 09/100 USD', 167.00, 0.00, '0.00', '0.00', 0.91, 1, 1, 1, 1, 1, '2024-11-06 15:53:49', 1),
(50, 'V00000050', '2024-11-06 15:49:29', 'EFECTIVO', 48, 2, 119.80, 4.19, 4.19, 0.00, 0.20, 123.99, 'Ciento veintitres 99/100 USD', 124.00, 0.00, '0.00', '0.00', 0.01, 1, 1, 1, 1, 1, '2024-11-06 15:49:47', 1),
(51, 'V00000051', '2024-11-08 08:19:14', 'EFECTIVO', 49, 1, 89.90, 6.29, 0.00, 0.00, 0.10, 96.19, 'Cientos noventa y seis 19/100 USD', 90.00, 0.00, '0.00', '0.00', -6.19, 1, 1, 1, 1, 1, '2024-11-08 08:32:16', 1),
(52, 'V00000052', '2024-11-08 15:36:29', 'EFECTIVO', 50, 1, 89.90, 6.29, 0.00, 0.00, 0.10, 96.19, 'Cientos noventa y seis 19/100 USD', 100.00, 0.00, '0.00', '0.00', 3.81, 1, 1, 1, 1, 1, '2024-11-08 15:37:05', 1),
(53, 'V00000053', '2024-11-12 09:52:46', 'EFECTIVO', 51, 2, 69.90, 4.89, 0.00, 0.00, 0.10, 74.79, 'Cientos setenta y cuatro 79/100 USD', 75.00, 0.00, '0.00', '0.00', 0.21, 1, 1, 1, 1, 1, '2024-11-15 15:13:06', 1),
(54, 'V00000054', '2024-11-12 09:53:11', 'EFECTIVO', 52, 1, 35.00, 2.45, 0.00, 0.00, 0.00, 37.45, 'Cientos treinta y siete 45/100 USD', 38.00, 0.00, '0.00', '0.00', 0.55, 1, 1, 1, 1, 1, '2024-11-12 09:53:40', 1),
(55, 'V00000055', '2024-11-15 12:57:08', 'EFECTIVO', 53, 1, 34.95, 2.45, 0.00, 0.00, 0.05, 37.40, 'Cientos treinta y siete 40/100 USD', 38.00, 0.00, '0.00', '0.00', 0.60, 1, 1, 1, 1, 1, '2024-11-15 12:57:26', 1),
(56, 'V00000056', '2024-11-15 14:58:08', 'EFECTIVO', 54, 1, 34.95, 2.45, 0.00, 0.00, 0.05, 37.40, 'Cientos treinta y siete 40/100 USD', 0.00, 0.00, '', '', 0.00, 1, 1, 1, NULL, NULL, NULL, 1),
(57, 'V00000057', '2024-11-15 14:58:11', 'EFECTIVO', 55, 1, 34.95, 2.45, 0.00, 0.00, 0.05, 37.40, 'Cientos treinta y siete 40/100 USD', 0.00, 0.00, '', '', 0.00, 1, 1, 1, NULL, NULL, NULL, 1),
(58, 'V00000058', '2024-11-15 14:58:23', 'EFECTIVO', 56, 1, 29.95, 2.10, 0.00, 0.00, 0.05, 32.05, 'Cientos treinta y dos 05/100 USD', 0.00, 0.00, '', '', 0.00, 1, 1, 1, NULL, NULL, NULL, 1),
(59, 'V00000059', '2024-11-15 14:58:50', 'EFECTIVO', 57, 1, 34.95, 2.45, 0.00, 0.00, 0.05, 37.40, 'Cientos treinta y siete 40/100 USD', 0.00, 0.00, '', '', 0.00, 1, 1, 1, NULL, NULL, NULL, 1),
(60, 'V00000060', '2024-11-15 14:59:27', 'EFECTIVO', 58, 1, 31.95, 0.00, 2.24, 0.00, 0.05, 31.95, 'Cientos treinta y uno 95/100 USD', 0.00, 0.00, '', '', 0.00, 1, 1, 1, NULL, NULL, NULL, 1),
(61, 'V00000061', '2024-11-15 15:01:11', 'EFECTIVO', 59, 1, 29.95, 2.10, 0.00, 0.00, 0.05, 32.05, 'Cientos treinta y dos 05/100 USD', 35.00, 0.00, '0.00', '0.00', 2.95, 1, 1, 1, 1, 1, '2024-11-15 15:02:05', 1),
(62, 'V00000062', '2024-11-15 15:10:16', 'EFECTIVO', 60, 1, 69.90, 0.00, 4.89, 0.00, 0.10, 69.90, 'Cientos sesenta y nueve 90/100 USD', 70.00, 0.00, '0.00', '0.00', 0.10, 1, 1, 1, 1, 1, '2024-11-15 15:11:11', 1),
(63, 'V00000063', '2024-11-15 15:13:55', 'EFECTIVO', 61, 2, 63.90, 0.00, 4.47, 0.00, 0.10, 63.90, 'Cientos sesenta y tres 90/100 USD', 65.00, 0.00, '0.00', '0.00', 1.10, 1, 1, 1, 1, 1, '2024-11-15 15:14:18', 1),
(64, 'V00000064', '2024-11-15 15:17:01', 'EFECTIVO', 62, 2, 104.85, 4.89, 2.45, 0.00, 0.15, 109.74, 'Ciento nueve 74/100 USD', 110.00, 0.00, '0.00', '0.00', 0.26, 1, 1, 1, 1, 1, '2024-11-15 15:17:12', 1),
(65, 'V00000065', '2024-11-15 15:59:09', 'EFECTIVO', 63, 2, 89.85, 4.19, 2.10, 0.00, 0.15, 94.04, 'Cientos noventa y cuatro 04/100 USD', 95.00, 0.00, '0.00', '0.00', 0.96, 1, 1, 1, 1, 1, '2024-11-15 15:59:25', 1),
(66, 'V00000066', '2024-11-15 16:00:07', 'EFECTIVO', 64, 1, 89.85, 4.19, 2.10, 0.00, 0.15, 94.04, 'Cientos noventa y cuatro 04/100 USD', 0.00, 0.00, '', '', 0.00, 1, NULL, 1, NULL, NULL, NULL, 1),
(67, 'V00000067', '2024-11-15 16:00:47', 'EFECTIVO', 65, 2, 89.85, 4.19, 2.10, 0.00, 0.15, 94.04, 'Cientos noventa y cuatro 04/100 USD', 95.00, 0.00, '0.00', '0.00', 0.96, 1, 1, 1, 1, 1, '2024-11-15 16:01:31', 1),
(68, 'V00000068', '2024-11-16 20:22:20', 'EFECTIVO', 66, 2, 89.85, 4.19, 2.10, 0.00, 0.15, 94.04, 'Cientos noventa y cuatro 04/100 USD', 95.00, 0.00, '0.00', '0.00', 0.96, 1, 1, 1, 1, 1, '2024-11-16 20:22:41', 1),
(69, 'V00000069', '2024-11-16 20:23:29', 'EFECTIVO', 67, 1, 89.85, 4.19, 2.10, 0.00, 0.15, 94.04, 'Cientos noventa y cuatro 04/100 USD', 95.00, 0.00, '0.00', '0.00', 0.96, 1, 1, 1, 1, 1, '2024-11-16 20:24:02', 1),
(70, 'V00000070', '2024-11-16 20:52:22', 'EFECTIVO', 68, 1, 89.85, 4.19, 2.10, 0.00, 0.15, 94.04, 'Cientos noventa y cuatro 04/100 USD', 95.00, 0.00, '0.00', '0.00', 0.96, 1, 1, 1, 1, 1, '2024-11-16 20:52:50', 1),
(71, 'V00000071', '2024-11-16 21:01:54', 'EFECTIVO', 69, 1, 164.75, 7.34, 4.19, 0.00, 0.25, 172.09, 'Ciento setenta y dos 09/100 USD', 173.00, 0.00, '0.00', '0.00', 0.91, 1, 1, 1, 1, 1, '2024-11-16 21:02:16', 1),
(72, 'V00000072', '2024-11-16 21:04:49', 'EFECTIVO', 70, 2, 149.75, 6.29, 4.19, 0.00, 0.25, 156.04, 'Ciento cincuenta y seis 04/100 USD', 157.00, 0.00, '0.00', '0.00', 0.96, 1, 1, 1, 1, 1, '2024-11-16 21:05:16', 1),
(73, 'V00000073', '2024-11-19 09:46:03', 'EFECTIVO', 71, 1, 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 0.00, 0.00, '', '', 0.00, 1, NULL, 1, NULL, NULL, NULL, 1),
(74, 'V00000074', '2024-11-19 09:47:01', 'EFECTIVO', 72, 1, 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 0.00, 0.00, '', '', 0.00, 1, NULL, 1, NULL, NULL, NULL, 1),
(75, 'V00000075', '2024-11-20 09:03:49', 'EFECTIVO', 73, 1, 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 0.00, 0.00, '', '', 0.00, 1, NULL, 1, NULL, NULL, NULL, 1),
(76, 'V00000076', '2024-11-20 09:52:09', 'EFECTIVO', 74, 2, 175.00, 0.00, 12.25, 0.00, 0.00, 175.00, 'Ciento setenta y cinco 00/100 USD', 180.00, 0.00, '0.00', '0.00', 5.00, 1, 1, 1, 1, 1, '2024-11-20 09:53:13', 1),
(77, 'V00000077', '2024-11-20 09:55:16', 'EFECTIVO', 75, 1, 150.00, 10.50, 0.00, 0.00, 0.00, 160.50, 'Ciento sesenta 50/100 USD', 0.00, 0.00, '', '', 0.00, 1, 1, 1, NULL, NULL, NULL, 1),
(78, 'V00000078', '2024-11-20 10:32:52', 'EFECTIVO', 76, 1, 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 0.00, 0.00, '', '', 0.00, 1, 1, 1, NULL, NULL, NULL, 1),
(79, 'V00000079', '2024-11-20 10:33:53', 'EFECTIVO', 77, 1, 40.00, 2.80, 0.00, 0.00, 0.00, 42.80, 'Cientos cuarenta y dos 80/100 USD', 43.00, 0.00, '0.00', '0.00', 0.20, 1, 1, 1, 1, 1, '2024-12-10 12:51:37', 1),
(80, 'V00000080', '2024-11-20 10:34:53', 'EFECTIVO', 78, 2, 30.00, 2.10, 0.00, 0.00, 0.00, 32.10, 'Cientos treinta y dos 10/100 USD', 35.00, 0.00, '0.00', '0.00', 2.90, 1, 1, 1, 1, 1, '2024-12-10 12:49:49', 1),
(81, 'V00000081', '2024-12-10 12:49:06', 'EFECTIVO', 79, 1, 129.80, 4.19, 4.89, 0.00, 0.20, 133.99, 'Ciento treinta y tres 99/100 USD', 134.00, 0.00, '0.00', '0.00', 0.01, 1, 1, 1, 1, 1, '2024-12-10 12:49:35', 1),
(82, 'V00000082', '2024-12-10 12:50:47', 'EFECTIVO', 80, 2, 129.80, 4.19, 4.89, 0.00, 0.20, 133.99, 'Ciento treinta y tres 99/100 USD', 135.00, 0.00, '0.00', '0.00', 1.01, 1, 1, 1, 1, 1, '2024-12-10 12:51:04', 1);

--
-- Triggers `venta`
--
DELIMITER $$
CREATE TRIGGER `generar_numero_venta` BEFORE INSERT ON `venta` FOR EACH ROW BEGIN

    

        DECLARE numero INT(11);



        SET numero = (SELECT max(idventa) FROM venta);

        

		IF numero IS NULL then

		  set numero=1;

        SET NEW.numero_venta='V00000001';



		ELSEIF numero >= 1 and numero < 9 then

			set numero=numero+1;

		SET NEW.numero_venta=(select concat('V0000000',CAST(numero AS CHAR)));

        

		ELSEIF numero >=9 and numero<=99 then

			set numero=numero+1;

		SET NEW.numero_venta=(select concat('V000000',CAST(numero AS CHAR)));

            

		ELSEIF numero>=99 and numero<=999 then

			set numero=numero+1;

		SET NEW.numero_venta=(select concat('V00000',CAST(numero AS CHAR)));

             

		ELSEIF numero>=999 and numero<=9999 then

		   set numero=numero+1;

		SET NEW.numero_venta=(select concat('V0000',CAST(numero AS CHAR)));

           

		ELSEIF numero>=9999 and numero<=99999 then

			set numero=numero+1;

		SET NEW.numero_venta=(select concat('V000',CAST(numero AS CHAR)));

             

		ELSEIF numero>=99999 and numero<=999999 then

			set numero=numero+1;

		SET NEW.numero_venta=(select concat('V00',CAST(numero AS CHAR)));

            

		ELSEIF numero>=999999 and numero<=9999999 then

			set numero=numero+1;

		SET NEW.numero_venta=(select concat('V0',CAST(numero AS CHAR)));

            

        ELSEIF numero>=9999999  then 			set numero=numero+1;

		SET NEW.numero_venta=(select concat('V',CAST(numero AS CHAR)));

            

		END IF;

    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_abonos`
-- (See below for the actual view)
--
CREATE TABLE `view_abonos` (
`idcredito` int(11)
,`codigo_credito` varchar(175)
,`nombre_credito` varchar(120)
,`idabono` int(11)
,`fecha_abono` datetime
,`monto_abono` decimal(13,2)
,`restante_credito` decimal(13,2)
,`total_abonado` decimal(13,2)
,`idusuario` int(11)
,`usuario` varchar(8)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_apartados`
-- (See below for the actual view)
--
CREATE TABLE `view_apartados` (
`idapartado` int(11)
,`numero_apartado` varchar(175)
,`fecha_apartado` datetime
,`fecha_limite_retiro` datetime
,`sumas` decimal(13,2)
,`iva` decimal(13,2)
,`total_exento` decimal(13,2)
,`retenido` decimal(13,2)
,`total_descuento` decimal(13,2)
,`total` decimal(13,2)
,`sonletras` varchar(150)
,`estado_apartado` tinyint(1)
,`idcliente` int(11)
,`cliente` varchar(150)
,`idproducto` int(11)
,`codigo_barra` varchar(200)
,`codigo_interno` varchar(175)
,`nombre_producto` varchar(175)
,`nombre_marca` varchar(120)
,`siglas` varchar(45)
,`producto_exento` tinyint(1)
,`perecedero` tinyint(1)
,`fecha_vence` date
,`cantidad` int(11)
,`precio_unitario` decimal(13,2)
,`precio_compra` decimal(13,2)
,`exento` decimal(13,2)
,`descuento` decimal(13,2)
,`importe` decimal(13,2)
,`empleado` varchar(181)
,`abonado_apartado` decimal(13,2)
,`restante_pagar` decimal(13,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_caja`
-- (See below for the actual view)
--
CREATE TABLE `view_caja` (
`idcaja` int(11)
,`fecha_apertura` datetime
,`monto_apertura` decimal(13,2)
,`monto_cierre` decimal(13,2)
,`fecha_cierre` datetime
,`estado` tinyint(1)
,`tipo_movimiento` tinyint(1)
,`monto_movimiento` decimal(13,2)
,`descripcion_movimiento` varchar(80)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_compras`
-- (See below for the actual view)
--
CREATE TABLE `view_compras` (
`idcompra` int(11)
,`fecha_compra` datetime
,`idproveedor` int(11)
,`nombre_proveedor` varchar(175)
,`numero_nit` varchar(70)
,`tipo_pago` varchar(75)
,`tipo_comprobante` varchar(60)
,`numero_comprobante` varchar(60)
,`fecha_comprobante` date
,`idproducto` int(11)
,`fecha_vence` date
,`codigo_barra` varchar(200)
,`codigo_interno` varchar(175)
,`nombre_producto` varchar(175)
,`nombre_marca` varchar(120)
,`siglas` varchar(45)
,`cantidad` int(11)
,`precio_unitario` decimal(13,2)
,`exento` decimal(13,2)
,`importe` decimal(13,2)
,`sumas` decimal(13,2)
,`iva` decimal(13,2)
,`total_exento` decimal(13,2)
,`retenido` decimal(13,2)
,`total` decimal(13,2)
,`sonletras` varchar(150)
,`estado_compra` tinyint(1)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_comprobantes`
-- (See below for the actual view)
--
CREATE TABLE `view_comprobantes` (
`idcomprobante` int(11)
,`nombre_comprobante` varchar(75)
,`estado` tinyint(1)
,`idtiraje` int(11)
,`fecha_resolucion` datetime
,`serie` varchar(175)
,`numero_resolucion` varchar(100)
,`desde` int(11)
,`hasta` int(11)
,`disponibles` int(11)
,`usados` bigint(12)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_cotizaciones`
-- (See below for the actual view)
--
CREATE TABLE `view_cotizaciones` (
`idcotizacion` int(11)
,`idVenta` int(11)
,`numero_cotizacion` varchar(175)
,`fecha_cotizacion` datetime
,`a_nombre` varchar(175)
,`nombre_cliente` varchar(150)
,`numero_nit` varchar(70)
,`direccion_cliente` varchar(100)
,`numero_telefono` varchar(70)
,`email` varchar(80)
,`tipo_pago` varchar(60)
,`entrega` varchar(60)
,`idproducto` int(11)
,`codigo_barra` varchar(200)
,`codigo_interno` varchar(175)
,`nombre_producto` varchar(175)
,`nombre_marca` varchar(120)
,`siglas` varchar(45)
,`stock` int(11)
,`cantidad` int(11)
,`disponible` tinyint(1)
,`precio_unitario` decimal(13,2)
,`exento` decimal(13,2)
,`descuento` decimal(13,2)
,`importe` decimal(13,2)
,`sumas` decimal(13,2)
,`iva` decimal(13,2)
,`total_exento` decimal(13,2)
,`retenido` decimal(13,2)
,`total_descuento` decimal(13,2)
,`total` decimal(13,2)
,`sonletras` varchar(150)
,`empleado` varchar(181)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_creditos_venta`
-- (See below for the actual view)
--
CREATE TABLE `view_creditos_venta` (
`idcredito` int(11)
,`codigo_credito` varchar(175)
,`idventa` int(11)
,`numero_venta` varchar(175)
,`nombre_credito` varchar(120)
,`fecha_credito` datetime
,`monto_credito` decimal(13,2)
,`monto_abonado` decimal(13,2)
,`monto_restante` decimal(13,2)
,`estado_credito` tinyint(1)
,`codigo_cliente` varchar(175)
,`cliente` varchar(150)
,`limite_credito` decimal(13,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_full_entradas`
-- (See below for the actual view)
--
CREATE TABLE `view_full_entradas` (
`idproducto` int(11)
,`codigo_interno` varchar(175)
,`codigo_barra` varchar(200)
,`nombre_producto` varchar(175)
,`nombre_marca` varchar(120)
,`siglas` varchar(45)
,`fecha_entrada` date
,`descripcion_entrada` varchar(150)
,`cantidad_entrada` int(11)
,`precio_unitario_entrada` decimal(13,2)
,`costo_total_entrada` decimal(13,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_full_salidas`
-- (See below for the actual view)
--
CREATE TABLE `view_full_salidas` (
`idproducto` int(11)
,`codigo_interno` varchar(175)
,`codigo_barra` varchar(200)
,`nombre_producto` varchar(175)
,`nombre_marca` varchar(120)
,`siglas` varchar(45)
,`fecha_salida` date
,`descripcion_salida` varchar(150)
,`cantidad_salida` int(11)
,`precio_unitario_salida` decimal(13,2)
,`costo_total_salida` decimal(13,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_historia`
-- (See below for the actual view)
--
CREATE TABLE `view_historia` (
`idhistorial` int(11)
,`num_historial` varchar(175)
,`codigo_interno` varchar(175)
,`codigo_barra` varchar(200)
,`codigo_alternativo` varchar(200)
,`idproducto` int(11)
,`nombre_producto` varchar(175)
,`tipo_movimiento` varchar(100)
,`stock_actual` int(11)
,`stock_anterior` int(11)
,`fecha_movimiento` datetime
,`idusuario` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_historial`
-- (See below for the actual view)
--
CREATE TABLE `view_historial` (
`idhistorial` int(11)
,`num_historial` varchar(175)
,`codigo_interno` varchar(175)
,`codigo_barra` varchar(200)
,`codigo_alternativo` varchar(200)
,`idproducto` int(11)
,`nombre_producto` varchar(175)
,`tipo_movimiento` varchar(100)
,`stock_actual` int(11)
,`stock_anterior` int(11)
,`fecha_movimiento` datetime
,`usuario` varchar(8)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_historico_precios`
-- (See below for the actual view)
--
CREATE TABLE `view_historico_precios` (
`idproducto` int(11)
,`codigo_interno` varchar(175)
,`codigo_barra` varchar(200)
,`nombre_producto` varchar(175)
,`nombre_marca` varchar(120)
,`siglas` varchar(45)
,`idproveedor` int(11)
,`nombre_proveedor` varchar(175)
,`fecha_precio` date
,`precio_comprado` decimal(13,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_kardex`
-- (See below for the actual view)
--
CREATE TABLE `view_kardex` (
`idproducto` int(11)
,`producto` varchar(222)
,`nombre_marca` varchar(120)
,`saldo_inicial` decimal(13,2)
,`entradas` int(11)
,`salidas` int(11)
,`saldo_final` decimal(13,2)
,`mes_inventario` varchar(7)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_perecederos`
-- (See below for the actual view)
--
CREATE TABLE `view_perecederos` (
`idproducto` int(11)
,`codigo_interno` varchar(175)
,`codigo_barra` varchar(200)
,`nombre_producto` varchar(175)
,`nombre_marca` varchar(120)
,`siglas` varchar(45)
,`fecha_vencimiento` date
,`cantidad_perecedero` decimal(13,2)
,`estado_perecedero` tinyint(1)
,`vencido` varchar(2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_productos`
-- (See below for the actual view)
--
CREATE TABLE `view_productos` (
`idproducto` int(11)
,`codigo_interno` varchar(175)
,`codigo_barra` varchar(200)
,`codigo_alternativo` varchar(200)
,`nombre_producto` varchar(175)
,`precio_compra` decimal(13,2)
,`precio_venta` decimal(13,2)
,`precio_venta1` decimal(13,2)
,`precio_venta2` decimal(13,2)
,`precio_venta3` decimal(13,2)
,`precio_venta_mayoreo` decimal(13,2)
,`stock` int(11)
,`stock_min` int(11)
,`idcategoria` int(11)
,`nombre_categoria` varchar(120)
,`idmarca` int(11)
,`nombre_marca` varchar(120)
,`idpresentacion` int(11)
,`nombre_presentacion` varchar(120)
,`siglas` varchar(45)
,`estado` tinyint(1)
,`exento` tinyint(1)
,`inventariable` tinyint(1)
,`perecedero` tinyint(1)
,`imagen` varchar(170)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_productos_apartado`
-- (See below for the actual view)
--
CREATE TABLE `view_productos_apartado` (
`idproducto` int(11)
,`codigo_interno` varchar(175)
,`codigo_barra` varchar(200)
,`codigo_alternativo` varchar(200)
,`nombre_producto` varchar(175)
,`siglas` varchar(45)
,`nombre_marca` varchar(120)
,`precio_venta` decimal(13,2)
,`precio_venta_mayoreo` decimal(13,2)
,`stock` int(11)
,`exento` tinyint(1)
,`perecedero` tinyint(1)
,`imagen` varchar(170)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_productos_venta`
-- (See below for the actual view)
--
CREATE TABLE `view_productos_venta` (
`idproducto` int(11)
,`codigo_interno` varchar(175)
,`codigo_barra` varchar(200)
,`codigo_alternativo` varchar(200)
,`nombre_producto` varchar(175)
,`siglas` varchar(45)
,`nombre_marca` varchar(120)
,`precio_venta` decimal(13,2)
,`precio_venta1` decimal(13,2)
,`precio_venta2` decimal(13,2)
,`precio_venta3` decimal(13,2)
,`precio_venta_mayoreo` decimal(13,2)
,`stock` int(11)
,`exento` tinyint(1)
,`perecedero` tinyint(1)
,`inventariable` tinyint(1)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_taller`
-- (See below for the actual view)
--
CREATE TABLE `view_taller` (
`idorden` int(11)
,`numero_orden` varchar(175)
,`fecha_ingreso` datetime
,`Placa` varchar(125)
,`AnioAuto` int(11)
,`montoRepuesto` decimal(13,2)
,`ManoObra` decimal(13,2)
,`horaObra` int(11)
,`modelo` varchar(125)
,`serie` varchar(125)
,`averia` varchar(200)
,`observaciones` varchar(200)
,`deposito_revision` int(11)
,`deposito_reparacion` int(11)
,`diagnostico` varchar(200)
,`estado_aparato` varchar(200)
,`repuestos` int(11)
,`mano_obra` decimal(13,2)
,`fecha_alta` datetime
,`fecha_retiro` datetime
,`ubicacion` varchar(150)
,`parcial_pagar` decimal(13,2)
,`idcliente` int(11)
,`nombre_cliente` varchar(150)
,`numero_nit` varchar(70)
,`numero_telefono` varchar(70)
,`idtecnico` int(11)
,`tecnico` varchar(150)
,`idmarca` int(11)
,`nombre_marca` varchar(120)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_usuarios`
-- (See below for the actual view)
--
CREATE TABLE `view_usuarios` (
`idusuario` int(11)
,`usuario` varchar(8)
,`contrasena` varchar(180)
,`tipo_usuario` tinyint(1)
,`estado` tinyint(1)
,`idempleado` int(11)
,`nombre_empleado` varchar(90)
,`apellido_empleado` varchar(90)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_ventas`
-- (See below for the actual view)
--
CREATE TABLE `view_ventas` (
`idventa` int(11)
,`numero_venta` varchar(175)
,`fecha_venta` datetime
,`tipo_pago` varchar(75)
,`numero_comprobante` int(11)
,`tipo_comprobante` tinyint(1)
,`pago_efectivo` decimal(13,2)
,`pago_tarjeta` decimal(13,2)
,`numero_tarjeta` varchar(16)
,`tarjeta_habiente` varchar(90)
,`cambio` decimal(13,2)
,`sumas` decimal(13,2)
,`iva` decimal(13,2)
,`total_exento` decimal(13,2)
,`retenido` decimal(13,2)
,`total_descuento` decimal(13,2)
,`total` decimal(13,2)
,`sonletras` varchar(150)
,`estado_venta` tinyint(1)
,`idcliente` int(11)
,`cliente` varchar(150)
,`idproducto` int(11)
,`codigo_barra` varchar(200)
,`codigo_interno` varchar(175)
,`nombre_producto` varchar(175)
,`nombre_marca` varchar(120)
,`siglas` varchar(45)
,`producto_exento` tinyint(1)
,`perecedero` tinyint(1)
,`fecha_vence` date
,`cantidad` int(11)
,`precio_unitario` decimal(13,2)
,`precio_compra` decimal(13,2)
,`exento` decimal(13,2)
,`descuento` decimal(13,2)
,`importe` decimal(13,2)
,`empleado` varchar(181)
);

-- --------------------------------------------------------

--
-- Structure for view `view_abonos`
--
DROP TABLE IF EXISTS `view_abonos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_abonos`  AS SELECT `view_creditos_venta`.`idcredito` AS `idcredito`, `view_creditos_venta`.`codigo_credito` AS `codigo_credito`, `view_creditos_venta`.`nombre_credito` AS `nombre_credito`, `abono`.`idabono` AS `idabono`, `abono`.`fecha_abono` AS `fecha_abono`, `abono`.`monto_abono` AS `monto_abono`, `abono`.`restante_credito` AS `restante_credito`, `abono`.`total_abonado` AS `total_abonado`, `abono`.`idusuario` AS `idusuario`, `view_usuarios`.`usuario` AS `usuario` FROM ((`abono` join `view_creditos_venta` on(`view_creditos_venta`.`idcredito` = `abono`.`idcredito`)) join `view_usuarios` on(`abono`.`idusuario` = `view_usuarios`.`idusuario`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_apartados`
--
DROP TABLE IF EXISTS `view_apartados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_apartados`  AS SELECT `apartado`.`idapartado` AS `idapartado`, `apartado`.`numero_apartado` AS `numero_apartado`, `apartado`.`fecha_apartado` AS `fecha_apartado`, `apartado`.`fecha_limite_retiro` AS `fecha_limite_retiro`, `apartado`.`sumas` AS `sumas`, `apartado`.`iva` AS `iva`, `apartado`.`exento` AS `total_exento`, `apartado`.`retenido` AS `retenido`, `apartado`.`descuento` AS `total_descuento`, `apartado`.`total` AS `total`, `apartado`.`sonletras` AS `sonletras`, `apartado`.`estado` AS `estado_apartado`, `apartado`.`idcliente` AS `idcliente`, `cliente`.`nombre_cliente` AS `cliente`, `detalleapartado`.`idproducto` AS `idproducto`, `view_productos`.`codigo_barra` AS `codigo_barra`, `view_productos`.`codigo_interno` AS `codigo_interno`, `view_productos`.`nombre_producto` AS `nombre_producto`, `view_productos`.`nombre_marca` AS `nombre_marca`, `view_productos`.`siglas` AS `siglas`, `view_productos`.`exento` AS `producto_exento`, `view_productos`.`perecedero` AS `perecedero`, `detalleapartado`.`fecha_vence` AS `fecha_vence`, `detalleapartado`.`cantidad` AS `cantidad`, `detalleapartado`.`precio_unitario` AS `precio_unitario`, `view_productos`.`precio_compra` AS `precio_compra`, `detalleapartado`.`exento` AS `exento`, `detalleapartado`.`descuento` AS `descuento`, `detalleapartado`.`importe` AS `importe`, concat(`view_usuarios`.`nombre_empleado`,' ',`view_usuarios`.`apellido_empleado`) AS `empleado`, `apartado`.`abonado_apartado` AS `abonado_apartado`, `apartado`.`restante_pagar` AS `restante_pagar` FROM ((((`apartado` join `detalleapartado` on(`detalleapartado`.`idapartado` = `apartado`.`idapartado`)) join `view_productos` on(`detalleapartado`.`idproducto` = `view_productos`.`idproducto`)) join `view_usuarios` on(`view_usuarios`.`idusuario` = `apartado`.`idusuario`)) left join `cliente` on(`apartado`.`idcliente` = `cliente`.`idcliente`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_caja`
--
DROP TABLE IF EXISTS `view_caja`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_caja`  AS SELECT `caja`.`idcaja` AS `idcaja`, `caja`.`fecha_apertura` AS `fecha_apertura`, `caja`.`monto_apertura` AS `monto_apertura`, `caja`.`monto_cierre` AS `monto_cierre`, `caja`.`fecha_cierre` AS `fecha_cierre`, `caja`.`estado` AS `estado`, `caja_movimiento`.`tipo_movimiento` AS `tipo_movimiento`, `caja_movimiento`.`monto_movimiento` AS `monto_movimiento`, `caja_movimiento`.`descripcion_movimiento` AS `descripcion_movimiento` FROM (`caja` join `caja_movimiento` on(`caja`.`idcaja` = `caja_movimiento`.`idcaja`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_compras`
--
DROP TABLE IF EXISTS `view_compras`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_compras`  AS SELECT `compra`.`idcompra` AS `idcompra`, `compra`.`fecha_compra` AS `fecha_compra`, `compra`.`idproveedor` AS `idproveedor`, `proveedor`.`nombre_proveedor` AS `nombre_proveedor`, `proveedor`.`numero_nit` AS `numero_nit`, `compra`.`tipo_pago` AS `tipo_pago`, `compra`.`tipo_comprobante` AS `tipo_comprobante`, `compra`.`numero_comprobante` AS `numero_comprobante`, `compra`.`fecha_comprobante` AS `fecha_comprobante`, `detallecompra`.`idproducto` AS `idproducto`, `detallecompra`.`fecha_vence` AS `fecha_vence`, `producto`.`codigo_barra` AS `codigo_barra`, `producto`.`codigo_interno` AS `codigo_interno`, `producto`.`nombre_producto` AS `nombre_producto`, `marca`.`nombre_marca` AS `nombre_marca`, `presentacion`.`siglas` AS `siglas`, `detallecompra`.`cantidad` AS `cantidad`, `detallecompra`.`precio_unitario` AS `precio_unitario`, `detallecompra`.`exento` AS `exento`, `detallecompra`.`importe` AS `importe`, `compra`.`sumas` AS `sumas`, `compra`.`iva` AS `iva`, `compra`.`exento` AS `total_exento`, `compra`.`retenido` AS `retenido`, `compra`.`total` AS `total`, `compra`.`sonletras` AS `sonletras`, `compra`.`estado` AS `estado_compra` FROM (((((`compra` join `detallecompra` on(`compra`.`idcompra` = `detallecompra`.`idcompra`)) join `proveedor` on(`proveedor`.`idproveedor` = `compra`.`idproveedor`)) join `producto` on(`detallecompra`.`idproducto` = `producto`.`idproducto`)) join `presentacion` on(`producto`.`idpresentacion` = `presentacion`.`idpresentacion`)) left join `marca` on(`producto`.`idmarca` = `marca`.`idmarca`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_comprobantes`
--
DROP TABLE IF EXISTS `view_comprobantes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_comprobantes`  AS SELECT `comprobante`.`idcomprobante` AS `idcomprobante`, `comprobante`.`nombre_comprobante` AS `nombre_comprobante`, `comprobante`.`estado` AS `estado`, `tiraje_comprobante`.`idtiraje` AS `idtiraje`, `tiraje_comprobante`.`fecha_resolucion` AS `fecha_resolucion`, `tiraje_comprobante`.`serie` AS `serie`, `tiraje_comprobante`.`numero_resolucion` AS `numero_resolucion`, `tiraje_comprobante`.`desde` AS `desde`, `tiraje_comprobante`.`hasta` AS `hasta`, `tiraje_comprobante`.`disponibles` AS `disponibles`, `tiraje_comprobante`.`hasta`- `tiraje_comprobante`.`disponibles` AS `usados` FROM (`comprobante` join `tiraje_comprobante` on(`comprobante`.`idcomprobante` = `tiraje_comprobante`.`idcomprobante`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_cotizaciones`
--
DROP TABLE IF EXISTS `view_cotizaciones`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_cotizaciones`  AS SELECT `cotizacion`.`idcotizacion` AS `idcotizacion`, `cotizacion`.`idVenta` AS `idVenta`, `cotizacion`.`numero_cotizacion` AS `numero_cotizacion`, `cotizacion`.`fecha_cotizacion` AS `fecha_cotizacion`, `cotizacion`.`a_nombre` AS `a_nombre`, `cliente`.`nombre_cliente` AS `nombre_cliente`, `cliente`.`numero_nit` AS `numero_nit`, `cliente`.`direccion_cliente` AS `direccion_cliente`, `cliente`.`numero_telefono` AS `numero_telefono`, `cliente`.`email` AS `email`, `cotizacion`.`tipo_pago` AS `tipo_pago`, `cotizacion`.`entrega` AS `entrega`, `detallecotizacion`.`idproducto` AS `idproducto`, `producto`.`codigo_barra` AS `codigo_barra`, `producto`.`codigo_interno` AS `codigo_interno`, `producto`.`nombre_producto` AS `nombre_producto`, `marca`.`nombre_marca` AS `nombre_marca`, `presentacion`.`siglas` AS `siglas`, `producto`.`stock` AS `stock`, `detallecotizacion`.`cantidad` AS `cantidad`, `detallecotizacion`.`disponible` AS `disponible`, `detallecotizacion`.`precio_unitario` AS `precio_unitario`, `detallecotizacion`.`exento` AS `exento`, `detallecotizacion`.`descuento` AS `descuento`, `detallecotizacion`.`importe` AS `importe`, `cotizacion`.`sumas` AS `sumas`, `cotizacion`.`iva` AS `iva`, `cotizacion`.`exento` AS `total_exento`, `cotizacion`.`retenido` AS `retenido`, `cotizacion`.`descuento` AS `total_descuento`, `cotizacion`.`total` AS `total`, `cotizacion`.`sonletras` AS `sonletras`, concat(`view_usuarios`.`nombre_empleado`,' ',`view_usuarios`.`apellido_empleado`) AS `empleado` FROM ((((((`cotizacion` join `detallecotizacion` on(`cotizacion`.`idcotizacion` = `detallecotizacion`.`idcotizacion`)) join `producto` on(`detallecotizacion`.`idproducto` = `producto`.`idproducto`)) join `presentacion` on(`producto`.`idpresentacion` = `presentacion`.`idpresentacion`)) left join `marca` on(`producto`.`idmarca` = `marca`.`idmarca`)) join `view_usuarios` on(`cotizacion`.`idusuario` = `view_usuarios`.`idusuario`)) join `cliente` on(`cotizacion`.`idcliente` = `cliente`.`idcliente`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_creditos_venta`
--
DROP TABLE IF EXISTS `view_creditos_venta`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_creditos_venta`  AS SELECT `credito`.`idcredito` AS `idcredito`, `credito`.`codigo_credito` AS `codigo_credito`, `credito`.`idventa` AS `idventa`, `venta`.`numero_venta` AS `numero_venta`, `credito`.`nombre_credito` AS `nombre_credito`, `credito`.`fecha_credito` AS `fecha_credito`, `credito`.`monto_credito` AS `monto_credito`, `credito`.`monto_abonado` AS `monto_abonado`, `credito`.`monto_restante` AS `monto_restante`, `credito`.`estado` AS `estado_credito`, `cliente`.`codigo_cliente` AS `codigo_cliente`, `cliente`.`nombre_cliente` AS `cliente`, `cliente`.`limite_credito` AS `limite_credito` FROM ((`credito` join `venta` on(`credito`.`idventa` = `venta`.`idventa`)) join `cliente` on(`credito`.`idcliente` = `cliente`.`idcliente`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_full_entradas`
--
DROP TABLE IF EXISTS `view_full_entradas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_full_entradas`  AS SELECT `entrada`.`idproducto` AS `idproducto`, `view_productos`.`codigo_interno` AS `codigo_interno`, `view_productos`.`codigo_barra` AS `codigo_barra`, `view_productos`.`nombre_producto` AS `nombre_producto`, `view_productos`.`nombre_marca` AS `nombre_marca`, `view_productos`.`siglas` AS `siglas`, `entrada`.`fecha_entrada` AS `fecha_entrada`, `entrada`.`descripcion_entrada` AS `descripcion_entrada`, `entrada`.`cantidad_entrada` AS `cantidad_entrada`, `entrada`.`precio_unitario_entrada` AS `precio_unitario_entrada`, `entrada`.`costo_total_entrada` AS `costo_total_entrada` FROM (`entrada` join `view_productos` on(`entrada`.`idproducto` = `view_productos`.`idproducto`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_full_salidas`
--
DROP TABLE IF EXISTS `view_full_salidas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_full_salidas`  AS SELECT `salida`.`idproducto` AS `idproducto`, `view_productos`.`codigo_interno` AS `codigo_interno`, `view_productos`.`codigo_barra` AS `codigo_barra`, `view_productos`.`nombre_producto` AS `nombre_producto`, `view_productos`.`nombre_marca` AS `nombre_marca`, `view_productos`.`siglas` AS `siglas`, `salida`.`fecha_salida` AS `fecha_salida`, `salida`.`descripcion_salida` AS `descripcion_salida`, `salida`.`cantidad_salida` AS `cantidad_salida`, `salida`.`precio_unitario_salida` AS `precio_unitario_salida`, `salida`.`costo_total_salida` AS `costo_total_salida` FROM (`salida` join `view_productos` on(`salida`.`idproducto` = `view_productos`.`idproducto`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_historia`
--
DROP TABLE IF EXISTS `view_historia`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_historia`  AS SELECT `historial`.`idhistorial` AS `idhistorial`, `historial`.`num_historial` AS `num_historial`, `historial`.`codigo_interno` AS `codigo_interno`, `historial`.`codigo_barra` AS `codigo_barra`, `historial`.`codigo_alternativo` AS `codigo_alternativo`, `historial`.`idproducto` AS `idproducto`, `historial`.`nombre_producto` AS `nombre_producto`, `historial`.`tipo_movimiento` AS `tipo_movimiento`, `historial`.`stock_actual` AS `stock_actual`, `historial`.`stock_anterior` AS `stock_anterior`, `historial`.`fecha_movimiento` AS `fecha_movimiento`, `historial`.`idusuario` AS `idusuario` FROM `historial` ;

-- --------------------------------------------------------

--
-- Structure for view `view_historial`
--
DROP TABLE IF EXISTS `view_historial`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_historial`  AS SELECT `historial`.`idhistorial` AS `idhistorial`, `historial`.`num_historial` AS `num_historial`, `historial`.`codigo_interno` AS `codigo_interno`, `historial`.`codigo_barra` AS `codigo_barra`, `historial`.`codigo_alternativo` AS `codigo_alternativo`, `historial`.`idproducto` AS `idproducto`, `historial`.`nombre_producto` AS `nombre_producto`, `historial`.`tipo_movimiento` AS `tipo_movimiento`, `historial`.`stock_actual` AS `stock_actual`, `historial`.`stock_anterior` AS `stock_anterior`, `historial`.`fecha_movimiento` AS `fecha_movimiento`, `usuario`.`usuario` AS `usuario` FROM (`historial` join `usuario` on(`historial`.`idusuario` = `usuario`.`idusuario`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_historico_precios`
--
DROP TABLE IF EXISTS `view_historico_precios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_historico_precios`  AS SELECT `proveedor_precio`.`idproducto` AS `idproducto`, `view_productos`.`codigo_interno` AS `codigo_interno`, `view_productos`.`codigo_barra` AS `codigo_barra`, `view_productos`.`nombre_producto` AS `nombre_producto`, `view_productos`.`nombre_marca` AS `nombre_marca`, `view_productos`.`siglas` AS `siglas`, `proveedor_precio`.`idproveedor` AS `idproveedor`, `proveedor`.`nombre_proveedor` AS `nombre_proveedor`, `proveedor_precio`.`fecha_precio` AS `fecha_precio`, `proveedor_precio`.`precio_compra` AS `precio_comprado` FROM ((`proveedor_precio` join `view_productos` on(`proveedor_precio`.`idproducto` = `view_productos`.`idproducto`)) join `proveedor` on(`proveedor_precio`.`idproveedor` = `proveedor`.`idproveedor`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_kardex`
--
DROP TABLE IF EXISTS `view_kardex`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_kardex`  AS SELECT `inventario`.`idproducto` AS `idproducto`, concat(`view_productos`.`nombre_producto`,'  ',`view_productos`.`siglas`) AS `producto`, `view_productos`.`nombre_marca` AS `nombre_marca`, `inventario`.`saldo_inicial` AS `saldo_inicial`, if(`inventario`.`entradas` is null,0,`inventario`.`entradas`) AS `entradas`, if(`inventario`.`salidas` is null,0,`inventario`.`salidas`) AS `salidas`, `inventario`.`saldo_final` AS `saldo_final`, `inventario`.`mes_inventario` AS `mes_inventario` FROM (`inventario` join `view_productos` on(`inventario`.`idproducto` = `view_productos`.`idproducto`)) GROUP BY `inventario`.`idproducto`, `inventario`.`mes_inventario` ;

-- --------------------------------------------------------

--
-- Structure for view `view_perecederos`
--
DROP TABLE IF EXISTS `view_perecederos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_perecederos`  AS SELECT `perecedero`.`idproducto` AS `idproducto`, `producto`.`codigo_interno` AS `codigo_interno`, `producto`.`codigo_barra` AS `codigo_barra`, `producto`.`nombre_producto` AS `nombre_producto`, `marca`.`nombre_marca` AS `nombre_marca`, `presentacion`.`siglas` AS `siglas`, `perecedero`.`fecha_vencimiento` AS `fecha_vencimiento`, `perecedero`.`cantidad_perecedero` AS `cantidad_perecedero`, `perecedero`.`estado` AS `estado_perecedero`, if(curdate() < `perecedero`.`fecha_vencimiento`,'NO','SI') AS `vencido` FROM (((`perecedero` join `producto` on(`perecedero`.`idproducto` = `producto`.`idproducto`)) join `presentacion` on(`producto`.`idpresentacion` = `presentacion`.`idpresentacion`)) left join `marca` on(`producto`.`idmarca` = `marca`.`idmarca`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_productos`
--
DROP TABLE IF EXISTS `view_productos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_productos`  AS SELECT `producto`.`idproducto` AS `idproducto`, `producto`.`codigo_interno` AS `codigo_interno`, `producto`.`codigo_barra` AS `codigo_barra`, `producto`.`codigo_alternativo` AS `codigo_alternativo`, `producto`.`nombre_producto` AS `nombre_producto`, `producto`.`precio_compra` AS `precio_compra`, `producto`.`precio_venta` AS `precio_venta`, `producto`.`precio_venta1` AS `precio_venta1`, `producto`.`precio_venta2` AS `precio_venta2`, `producto`.`precio_venta3` AS `precio_venta3`, `producto`.`precio_venta_mayoreo` AS `precio_venta_mayoreo`, `producto`.`stock` AS `stock`, `producto`.`stock_min` AS `stock_min`, `producto`.`idcategoria` AS `idcategoria`, `categoria`.`nombre_categoria` AS `nombre_categoria`, `producto`.`idmarca` AS `idmarca`, `marca`.`nombre_marca` AS `nombre_marca`, `producto`.`idpresentacion` AS `idpresentacion`, `presentacion`.`nombre_presentacion` AS `nombre_presentacion`, `presentacion`.`siglas` AS `siglas`, `producto`.`estado` AS `estado`, `producto`.`exento` AS `exento`, `producto`.`inventariable` AS `inventariable`, `producto`.`perecedero` AS `perecedero`, `producto`.`imagen` AS `imagen` FROM (((`producto` join `categoria` on(`producto`.`idcategoria` = `categoria`.`idcategoria`)) join `presentacion` on(`producto`.`idpresentacion` = `presentacion`.`idpresentacion`)) left join `marca` on(`producto`.`idmarca` = `marca`.`idmarca`)) GROUP BY `producto`.`idproducto` ;

-- --------------------------------------------------------

--
-- Structure for view `view_productos_apartado`
--
DROP TABLE IF EXISTS `view_productos_apartado`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_productos_apartado`  AS SELECT `view_productos`.`idproducto` AS `idproducto`, `view_productos`.`codigo_interno` AS `codigo_interno`, `view_productos`.`codigo_barra` AS `codigo_barra`, `view_productos`.`codigo_alternativo` AS `codigo_alternativo`, `view_productos`.`nombre_producto` AS `nombre_producto`, `view_productos`.`siglas` AS `siglas`, `view_productos`.`nombre_marca` AS `nombre_marca`, `view_productos`.`precio_venta` AS `precio_venta`, `view_productos`.`precio_venta_mayoreo` AS `precio_venta_mayoreo`, `view_productos`.`stock` AS `stock`, `view_productos`.`exento` AS `exento`, `view_productos`.`perecedero` AS `perecedero`, `view_productos`.`imagen` AS `imagen` FROM `view_productos` WHERE `view_productos`.`stock` > 0.00 AND `view_productos`.`precio_venta` > 0.00 AND `view_productos`.`estado` = 1 AND `view_productos`.`perecedero` = 0 AND `view_productos`.`inventariable` = 1 GROUP BY `view_productos`.`idproducto` ;

-- --------------------------------------------------------

--
-- Structure for view `view_productos_venta`
--
DROP TABLE IF EXISTS `view_productos_venta`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_productos_venta`  AS SELECT `view_productos`.`idproducto` AS `idproducto`, `view_productos`.`codigo_interno` AS `codigo_interno`, `view_productos`.`codigo_barra` AS `codigo_barra`, `view_productos`.`codigo_alternativo` AS `codigo_alternativo`, `view_productos`.`nombre_producto` AS `nombre_producto`, `view_productos`.`siglas` AS `siglas`, `view_productos`.`nombre_marca` AS `nombre_marca`, `view_productos`.`precio_venta` AS `precio_venta`, `view_productos`.`precio_venta1` AS `precio_venta1`, `view_productos`.`precio_venta2` AS `precio_venta2`, `view_productos`.`precio_venta3` AS `precio_venta3`, `view_productos`.`precio_venta_mayoreo` AS `precio_venta_mayoreo`, `view_productos`.`stock` AS `stock`, `view_productos`.`exento` AS `exento`, `view_productos`.`perecedero` AS `perecedero`, `view_productos`.`inventariable` AS `inventariable` FROM `view_productos` WHERE `view_productos`.`stock` > 0.00 AND `view_productos`.`precio_venta` > 0.00 AND `view_productos`.`estado` = 1 AND (`view_productos`.`inventariable` = 1 OR `view_productos`.`inventariable` = 0) GROUP BY `view_productos`.`idproducto` ;

-- --------------------------------------------------------

--
-- Structure for view `view_taller`
--
DROP TABLE IF EXISTS `view_taller`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_taller`  AS SELECT `ordentaller`.`idorden` AS `idorden`, `ordentaller`.`numero_orden` AS `numero_orden`, `ordentaller`.`fecha_ingreso` AS `fecha_ingreso`, `ordentaller`.`Placa` AS `Placa`, `ordentaller`.`AnioAuto` AS `AnioAuto`, `ordentaller`.`montoRepuesto` AS `montoRepuesto`, `ordentaller`.`ManoObra` AS `ManoObra`, `ordentaller`.`horaObra` AS `horaObra`, `ordentaller`.`modelo` AS `modelo`, coalesce(`ordentaller`.`Placa`,'') AS `serie`, `ordentaller`.`averia` AS `averia`, `ordentaller`.`observaciones` AS `observaciones`, `ordentaller`.`deposito_revision` AS `deposito_revision`, `ordentaller`.`deposito_reparacion` AS `deposito_reparacion`, `ordentaller`.`diagnostico` AS `diagnostico`, `ordentaller`.`estado_aparato` AS `estado_aparato`, `ordentaller`.`repuestos` AS `repuestos`, `ordentaller`.`mano_obra` AS `mano_obra`, `ordentaller`.`fecha_alta` AS `fecha_alta`, `ordentaller`.`fecha_retiro` AS `fecha_retiro`, `ordentaller`.`ubicacion` AS `ubicacion`, `ordentaller`.`parcial_pagar` AS `parcial_pagar`, `ordentaller`.`idcliente` AS `idcliente`, `cliente`.`nombre_cliente` AS `nombre_cliente`, `cliente`.`numero_nit` AS `numero_nit`, `cliente`.`numero_telefono` AS `numero_telefono`, `ordentaller`.`idtecnico` AS `idtecnico`, `tecnico`.`tecnico` AS `tecnico`, `ordentaller`.`idmarca` AS `idmarca`, `marca`.`nombre_marca` AS `nombre_marca` FROM (((`ordentaller` join `cliente` on(`ordentaller`.`idcliente` = `cliente`.`idcliente`)) join `marca` on(`ordentaller`.`idmarca` = `marca`.`idmarca`)) join `tecnico` on(`ordentaller`.`idtecnico` = `tecnico`.`idtecnico`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_usuarios`
--
DROP TABLE IF EXISTS `view_usuarios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_usuarios`  AS SELECT `usuario`.`idusuario` AS `idusuario`, `usuario`.`usuario` AS `usuario`, `usuario`.`contrasena` AS `contrasena`, `usuario`.`tipo_usuario` AS `tipo_usuario`, `usuario`.`estado` AS `estado`, `usuario`.`idempleado` AS `idempleado`, `empleado`.`nombre_empleado` AS `nombre_empleado`, `empleado`.`apellido_empleado` AS `apellido_empleado` FROM (`usuario` join `empleado` on(`usuario`.`idempleado` = `empleado`.`idempleado`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_ventas`
--
DROP TABLE IF EXISTS `view_ventas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_ventas`  AS SELECT `venta`.`idventa` AS `idventa`, `venta`.`numero_venta` AS `numero_venta`, `venta`.`fecha_venta` AS `fecha_venta`, `venta`.`tipo_pago` AS `tipo_pago`, `venta`.`numero_comprobante` AS `numero_comprobante`, `venta`.`tipo_comprobante` AS `tipo_comprobante`, `venta`.`pago_efectivo` AS `pago_efectivo`, `venta`.`pago_tarjeta` AS `pago_tarjeta`, `venta`.`numero_tarjeta` AS `numero_tarjeta`, `venta`.`tarjeta_habiente` AS `tarjeta_habiente`, `venta`.`cambio` AS `cambio`, `venta`.`sumas` AS `sumas`, `venta`.`iva` AS `iva`, `venta`.`exento` AS `total_exento`, `venta`.`retenido` AS `retenido`, `venta`.`descuento` AS `total_descuento`, `venta`.`total` AS `total`, `venta`.`sonletras` AS `sonletras`, `venta`.`estado` AS `estado_venta`, `venta`.`idcliente` AS `idcliente`, `cliente`.`nombre_cliente` AS `cliente`, `detalleventa`.`idproducto` AS `idproducto`, `view_productos`.`codigo_barra` AS `codigo_barra`, `view_productos`.`codigo_interno` AS `codigo_interno`, `view_productos`.`nombre_producto` AS `nombre_producto`, `view_productos`.`nombre_marca` AS `nombre_marca`, `view_productos`.`siglas` AS `siglas`, `view_productos`.`exento` AS `producto_exento`, `view_productos`.`perecedero` AS `perecedero`, `detalleventa`.`fecha_vence` AS `fecha_vence`, `detalleventa`.`cantidad` AS `cantidad`, `detalleventa`.`precio_unitario` AS `precio_unitario`, `view_productos`.`precio_compra` AS `precio_compra`, `detalleventa`.`exento` AS `exento`, `detalleventa`.`descuento` AS `descuento`, `detalleventa`.`importe` AS `importe`, concat(`view_usuarios`.`nombre_empleado`,' ',`view_usuarios`.`apellido_empleado`) AS `empleado` FROM ((((`venta` join `detalleventa` on(`detalleventa`.`idventa` = `venta`.`idventa`)) join `view_productos` on(`detalleventa`.`idproducto` = `view_productos`.`idproducto`)) join `view_usuarios` on(`view_usuarios`.`idusuario` = `venta`.`idusuario`)) left join `cliente` on(`venta`.`idcliente` = `cliente`.`idcliente`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `abono`
--
ALTER TABLE `abono`
  ADD PRIMARY KEY (`idabono`),
  ADD KEY `fk_abono_credito1_idx` (`idcredito`),
  ADD KEY `fk_abono_usuario1_idx` (`idusuario`);

--
-- Indexes for table `apartado`
--
ALTER TABLE `apartado`
  ADD PRIMARY KEY (`idapartado`),
  ADD UNIQUE KEY `numero_venta_UNIQUE` (`numero_apartado`),
  ADD KEY `fk_venta_cliente1_idx` (`idcliente`),
  ADD KEY `fk_venta_usuario1_idx` (`idusuario`);

--
-- Indexes for table `caja`
--
ALTER TABLE `caja`
  ADD PRIMARY KEY (`idcaja`);

--
-- Indexes for table `caja_movimiento`
--
ALTER TABLE `caja_movimiento`
  ADD KEY `fk_caja_movimiento_caja1_idx` (`idcaja`);

--
-- Indexes for table `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`idcategoria`);

--
-- Indexes for table `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`idcliente`),
  ADD UNIQUE KEY `codigo_cliente_UNIQUE` (`codigo_cliente`),
  ADD KEY `iddias` (`iddias`);

--
-- Indexes for table `compra`
--
ALTER TABLE `compra`
  ADD PRIMARY KEY (`idcompra`),
  ADD KEY `fk_compra_proveedor1_idx` (`idproveedor`);

--
-- Indexes for table `comprobante`
--
ALTER TABLE `comprobante`
  ADD PRIMARY KEY (`idcomprobante`);

--
-- Indexes for table `cotizacion`
--
ALTER TABLE `cotizacion`
  ADD PRIMARY KEY (`idcotizacion`),
  ADD KEY `fk_cotizacion_usuario1_idx` (`idusuario`),
  ADD KEY `fk_cotizacion_cliente1_idx` (`idcliente`);

--
-- Indexes for table `credito`
--
ALTER TABLE `credito`
  ADD PRIMARY KEY (`idcredito`),
  ADD KEY `fk_credito_venta1_idx` (`idventa`),
  ADD KEY `fk_credito_cliente1_idx` (`idcliente`);

--
-- Indexes for table `currency`
--
ALTER TABLE `currency`
  ADD PRIMARY KEY (`idcurrency`);

--
-- Indexes for table `detalleapartado`
--
ALTER TABLE `detalleapartado`
  ADD KEY `fk_detalleventa_producto1_idx` (`idproducto`),
  ADD KEY `fk_detalleapartado_apartado1_idx` (`idapartado`);

--
-- Indexes for table `detallecompra`
--
ALTER TABLE `detallecompra`
  ADD KEY `fk_detallecompra_producto1_idx` (`idproducto`),
  ADD KEY `fk_detallecompra_compra1_idx` (`idcompra`);

--
-- Indexes for table `detallecotizacion`
--
ALTER TABLE `detallecotizacion`
  ADD KEY `fk_detallecotizacion_producto1_idx` (`idproducto`),
  ADD KEY `fk_detallecotizacion_cotizacion1_idx` (`idcotizacion`);

--
-- Indexes for table `detalleventa`
--
ALTER TABLE `detalleventa`
  ADD KEY `fk_detalleventa_venta1_idx` (`idventa`),
  ADD KEY `fk_detalleventa_producto1_idx` (`idproducto`);

--
-- Indexes for table `detalle_ordentaller`
--
ALTER TABLE `detalle_ordentaller`
  ADD PRIMARY KEY (`idDetalle`);

--
-- Indexes for table `dias`
--
ALTER TABLE `dias`
  ADD PRIMARY KEY (`iddias`);

--
-- Indexes for table `empleado`
--
ALTER TABLE `empleado`
  ADD PRIMARY KEY (`idempleado`),
  ADD UNIQUE KEY `codigo_empleado_UNIQUE` (`codigo_empleado`);

--
-- Indexes for table `entrada`
--
ALTER TABLE `entrada`
  ADD PRIMARY KEY (`identrada`),
  ADD KEY `fk_entrada_producto1_idx` (`idproducto`),
  ADD KEY `fk_entrada_compra1_idx` (`idcompra`),
  ADD KEY `fk_entrada_apartado1_idx` (`idapartado`);

--
-- Indexes for table `historial`
--
ALTER TABLE `historial`
  ADD PRIMARY KEY (`idhistorial`),
  ADD UNIQUE KEY `num_historial` (`num_historial`);

--
-- Indexes for table `inventario`
--
ALTER TABLE `inventario`
  ADD KEY `fk_inventario_producto1_idx` (`idproducto`);

--
-- Indexes for table `marca`
--
ALTER TABLE `marca`
  ADD PRIMARY KEY (`idmarca`);

--
-- Indexes for table `ordentaller`
--
ALTER TABLE `ordentaller`
  ADD PRIMARY KEY (`idorden`),
  ADD KEY `fk_ordentaller_cliente1_idx` (`idcliente`),
  ADD KEY `fk_ordentaller_marca1_idx` (`idmarca`),
  ADD KEY `fk_ordentaller_tecnico1_idx` (`idtecnico`);

--
-- Indexes for table `parametro`
--
ALTER TABLE `parametro`
  ADD PRIMARY KEY (`idparametro`),
  ADD KEY `fk_parametro_currency1_idx` (`idcurrency`);

--
-- Indexes for table `perecedero`
--
ALTER TABLE `perecedero`
  ADD KEY `fk_perecedero_producto1_idx` (`idproducto`);

--
-- Indexes for table `presentacion`
--
ALTER TABLE `presentacion`
  ADD PRIMARY KEY (`idpresentacion`);

--
-- Indexes for table `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`idproducto`),
  ADD UNIQUE KEY `codigo_interno_UNIQUE` (`codigo_interno`),
  ADD UNIQUE KEY `codigo_alternativo` (`codigo_alternativo`),
  ADD UNIQUE KEY `codigo_barra` (`codigo_barra`),
  ADD KEY `fk_producto_categoria_idx` (`idcategoria`),
  ADD KEY `fk_producto_presentacion1_idx` (`idpresentacion`),
  ADD KEY `fk_producto_marca1_idx` (`idmarca`),
  ADD KEY `fk_producto_usuario` (`usuario`);

--
-- Indexes for table `producto_proveedor`
--
ALTER TABLE `producto_proveedor`
  ADD KEY `fk_producto_proveedor_proveedor1_idx` (`idproveedor`),
  ADD KEY `fk_producto_proveedor_producto1_idx` (`idproducto`);

--
-- Indexes for table `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`idproveedor`),
  ADD UNIQUE KEY `nombre_proveedor_UNIQUE` (`nombre_proveedor`),
  ADD UNIQUE KEY `codigo_proveedor_UNIQUE` (`codigo_proveedor`);

--
-- Indexes for table `proveedor_precio`
--
ALTER TABLE `proveedor_precio`
  ADD KEY `fk_proveedor_precio_proveedor1_idx` (`idproveedor`),
  ADD KEY `fk_proveedor_precio_producto1_idx` (`idproducto`);

--
-- Indexes for table `salida`
--
ALTER TABLE `salida`
  ADD PRIMARY KEY (`idsalida`),
  ADD KEY `fk_entrada_producto1_idx` (`idproducto`),
  ADD KEY `fk_salida_venta1_idx` (`idventa`),
  ADD KEY `fk_salida_apartado1_idx` (`idapartado`);

--
-- Indexes for table `tecnico`
--
ALTER TABLE `tecnico`
  ADD PRIMARY KEY (`idtecnico`);

--
-- Indexes for table `tiraje_comprobante`
--
ALTER TABLE `tiraje_comprobante`
  ADD PRIMARY KEY (`idtiraje`),
  ADD KEY `fk_tiraje_comprobante_comprobante1_idx` (`idcomprobante`);

--
-- Indexes for table `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idusuario`),
  ADD KEY `fk_usuario_empleado1_idx` (`idempleado`);

--
-- Indexes for table `venta`
--
ALTER TABLE `venta`
  ADD PRIMARY KEY (`idventa`),
  ADD UNIQUE KEY `numero_venta_UNIQUE` (`numero_venta`),
  ADD KEY `fk_venta_cliente1_idx` (`idcliente`),
  ADD KEY `fk_venta_usuario1_idx` (`idusuario`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `abono`
--
ALTER TABLE `abono`
  MODIFY `idabono` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `apartado`
--
ALTER TABLE `apartado`
  MODIFY `idapartado` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `caja`
--
ALTER TABLE `caja`
  MODIFY `idcaja` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `categoria`
--
ALTER TABLE `categoria`
  MODIFY `idcategoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `cliente`
--
ALTER TABLE `cliente`
  MODIFY `idcliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `compra`
--
ALTER TABLE `compra`
  MODIFY `idcompra` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `comprobante`
--
ALTER TABLE `comprobante`
  MODIFY `idcomprobante` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `cotizacion`
--
ALTER TABLE `cotizacion`
  MODIFY `idcotizacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `credito`
--
ALTER TABLE `credito`
  MODIFY `idcredito` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `currency`
--
ALTER TABLE `currency`
  MODIFY `idcurrency` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `detalle_ordentaller`
--
ALTER TABLE `detalle_ordentaller`
  MODIFY `idDetalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `dias`
--
ALTER TABLE `dias`
  MODIFY `iddias` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `empleado`
--
ALTER TABLE `empleado`
  MODIFY `idempleado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `entrada`
--
ALTER TABLE `entrada`
  MODIFY `identrada` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `historial`
--
ALTER TABLE `historial`
  MODIFY `idhistorial` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=137;

--
-- AUTO_INCREMENT for table `marca`
--
ALTER TABLE `marca`
  MODIFY `idmarca` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `ordentaller`
--
ALTER TABLE `ordentaller`
  MODIFY `idorden` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `parametro`
--
ALTER TABLE `parametro`
  MODIFY `idparametro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `presentacion`
--
ALTER TABLE `presentacion`
  MODIFY `idpresentacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `producto`
--
ALTER TABLE `producto`
  MODIFY `idproducto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `idproveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `salida`
--
ALTER TABLE `salida`
  MODIFY `idsalida` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=134;

--
-- AUTO_INCREMENT for table `tecnico`
--
ALTER TABLE `tecnico`
  MODIFY `idtecnico` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `tiraje_comprobante`
--
ALTER TABLE `tiraje_comprobante`
  MODIFY `idtiraje` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idusuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `venta`
--
ALTER TABLE `venta`
  MODIFY `idventa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `abono`
--
ALTER TABLE `abono`
  ADD CONSTRAINT `fk_abono_credito1` FOREIGN KEY (`idcredito`) REFERENCES `credito` (`idcredito`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_abono_usuario1` FOREIGN KEY (`idusuario`) REFERENCES `usuario` (`idusuario`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `apartado`
--
ALTER TABLE `apartado`
  ADD CONSTRAINT `fk_venta_cliente0` FOREIGN KEY (`idcliente`) REFERENCES `cliente` (`idcliente`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_venta_usuario0` FOREIGN KEY (`idusuario`) REFERENCES `usuario` (`idusuario`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `caja_movimiento`
--
ALTER TABLE `caja_movimiento`
  ADD CONSTRAINT `fk_caja_movimiento_caja` FOREIGN KEY (`idcaja`) REFERENCES `caja` (`idcaja`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `fk_cliente_dias` FOREIGN KEY (`iddias`) REFERENCES `dias` (`iddias`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `compra`
--
ALTER TABLE `compra`
  ADD CONSTRAINT `fk_compra_proveedor` FOREIGN KEY (`idproveedor`) REFERENCES `proveedor` (`idproveedor`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `cotizacion`
--
ALTER TABLE `cotizacion`
  ADD CONSTRAINT `fk_cotizacion_cliente1` FOREIGN KEY (`idcliente`) REFERENCES `cliente` (`idcliente`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_cotizacion_usuario1` FOREIGN KEY (`idusuario`) REFERENCES `usuario` (`idusuario`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `credito`
--
ALTER TABLE `credito`
  ADD CONSTRAINT `fk_credito_cliente1` FOREIGN KEY (`idcliente`) REFERENCES `cliente` (`idcliente`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_credito_venta1` FOREIGN KEY (`idventa`) REFERENCES `venta` (`idventa`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `detalleapartado`
--
ALTER TABLE `detalleapartado`
  ADD CONSTRAINT `fk_detalleapartado_apartado1` FOREIGN KEY (`idapartado`) REFERENCES `apartado` (`idapartado`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_detalleventa_producto0` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `detallecompra`
--
ALTER TABLE `detallecompra`
  ADD CONSTRAINT `fk_detallecompra_compra` FOREIGN KEY (`idcompra`) REFERENCES `compra` (`idcompra`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_detallecompra_producto` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `detallecotizacion`
--
ALTER TABLE `detallecotizacion`
  ADD CONSTRAINT `fk_detallecotizacion_cotizacion1` FOREIGN KEY (`idcotizacion`) REFERENCES `cotizacion` (`idcotizacion`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_detallecotizacion_producto1` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `detalleventa`
--
ALTER TABLE `detalleventa`
  ADD CONSTRAINT `fk_detalleventa_producto` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_detalleventa_venta` FOREIGN KEY (`idventa`) REFERENCES `venta` (`idventa`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `entrada`
--
ALTER TABLE `entrada`
  ADD CONSTRAINT `fk_entrada_apartado` FOREIGN KEY (`idapartado`) REFERENCES `apartado` (`idapartado`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_entrada_compra` FOREIGN KEY (`idcompra`) REFERENCES `compra` (`idcompra`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_entrada_producto` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `inventario`
--
ALTER TABLE `inventario`
  ADD CONSTRAINT `fk_inventario_producto` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `ordentaller`
--
ALTER TABLE `ordentaller`
  ADD CONSTRAINT `fk_ordentaller_cliente` FOREIGN KEY (`idcliente`) REFERENCES `cliente` (`idcliente`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ordentaller_marca` FOREIGN KEY (`idmarca`) REFERENCES `marca` (`idmarca`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ordentaller_tecnico` FOREIGN KEY (`idtecnico`) REFERENCES `tecnico` (`idtecnico`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `parametro`
--
ALTER TABLE `parametro`
  ADD CONSTRAINT `fk_parametro_currency1` FOREIGN KEY (`idcurrency`) REFERENCES `currency` (`idcurrency`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `perecedero`
--
ALTER TABLE `perecedero`
  ADD CONSTRAINT `fk_perecedero_producto` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `fk_producto_categoria` FOREIGN KEY (`idcategoria`) REFERENCES `categoria` (`idcategoria`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_producto_marca` FOREIGN KEY (`idmarca`) REFERENCES `marca` (`idmarca`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_producto_presentacion` FOREIGN KEY (`idpresentacion`) REFERENCES `presentacion` (`idpresentacion`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_producto_usuario` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `producto_proveedor`
--
ALTER TABLE `producto_proveedor`
  ADD CONSTRAINT `fk_producto_proveedor_producto` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_producto_proveedor_proveedor` FOREIGN KEY (`idproveedor`) REFERENCES `proveedor` (`idproveedor`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `proveedor_precio`
--
ALTER TABLE `proveedor_precio`
  ADD CONSTRAINT `fk_proveedor_precio_producto` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_proveedor_precio_proveedor` FOREIGN KEY (`idproveedor`) REFERENCES `proveedor` (`idproveedor`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `salida`
--
ALTER TABLE `salida`
  ADD CONSTRAINT `fk_salida_apartado` FOREIGN KEY (`idapartado`) REFERENCES `apartado` (`idapartado`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_salida_producto` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_salida_venta` FOREIGN KEY (`idventa`) REFERENCES `venta` (`idventa`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tiraje_comprobante`
--
ALTER TABLE `tiraje_comprobante`
  ADD CONSTRAINT `fk_tiraje_comprobante_comprobante` FOREIGN KEY (`idcomprobante`) REFERENCES `comprobante` (`idcomprobante`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `fk_usuario_empleado` FOREIGN KEY (`idempleado`) REFERENCES `empleado` (`idempleado`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `fk_venta_cliente` FOREIGN KEY (`idcliente`) REFERENCES `cliente` (`idcliente`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_venta_usuario` FOREIGN KEY (`idusuario`) REFERENCES `usuario` (`idusuario`) ON DELETE NO ACTION ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
