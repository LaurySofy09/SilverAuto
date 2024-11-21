<?php

	class Cotizacion {

		public static function Autocomplete_Producto($search){

			$filas = CotizacionModel::Autocomplete_Producto($search);
			return $filas;

		}

		public static function Ver_Moneda_Reporte(){

			$filas = CotizacionModel::Ver_Moneda_Reporte();
			return $filas;

		}

		public static function Listar_Cotizaciones($date,$date2){

			$filas = CotizacionModel::Listar_Cotizaciones($date,$date2);
			return $filas;

		}

		public static function Listar_Detalle($idCotizacion){

			$filas = CotizacionModel::Listar_Detalle($idCotizacion);
			return $filas;

		}

		public static function Listar_Objetos($idCotizacion){

			$filas = CotizacionModel::Listar_Objetos($idCotizacion);
			return $filas;

		}

		public static function Listar_Info($idCotizacion){

			$filas = CotizacionModel::Listar_Info($idCotizacion);
			return $filas;

		}

		public static function Count_Cotizaciones($date,$date2){

			$filas = CotizacionModel::Count_Cotizaciones($date,$date2);
			return $filas;

		}
		
		public static function ActualizarCotizacionFactura($idCotizacion)
		{
			$filas = CotizacionModel::ActualizarCotizacionFactura($idCotizacion);
			return $filas;
		}

		public static function Insertar_Cotizacion($a_nombre, $tipo_pago, $entrega,
		$sumas, $iva, $exento, $retenido, $descuento, $total, $sonletras, $idusuario, $idcliente){

		$cmd = CotizacionModel::Insertar_Cotizacion($a_nombre, $tipo_pago, $entrega,
		$sumas, $iva, $exento, $retenido, $descuento, $total, $sonletras, $idusuario, $idcliente);

		}

		public static function Insertar_DetalleCotizacion($idproducto, $cantidad, $disponible, $precio_unitario, $exento, $descuento, $importe){

		$cmd = CotizacionModel::Insertar_DetalleCotizacion($idproducto, $cantidad, $disponible, $precio_unitario, $exento, $descuento, $importe);

		}


		public static function Borrar_Cotizacion($idCotizacion){

		$cmd = CotizacionModel::Borrar_Cotizacion($idCotizacion);

		}


		public static function Mostrar_Cliente($idCotizacion){

			$filas = CotizacionModel::Mostrar_Cliente($idCotizacion);
			return $filas;

		}

		public static function Ver_Limite_Credito($idcliente){

			$filas = ClienteModel::Ver_Limite_Credito($idcliente);
			return $filas;

		}

		public static function Insertar_Venta($tipo_pago, $tipo_comprobante,
		$sumas, $iva, $exento, $retenido, $descuento, $total, $sonletras, $pago_efectivo, $pago_tarjeta, $numero_tarjeta, $tarjeta_habiente,
		$cambio, $estado, $idcliente, $idusuario){

		$cmd = CotizacionModel::Insertar_Venta($tipo_pago, $tipo_comprobante,
		$sumas, $iva, $exento, $retenido, $descuento, $total, $sonletras, $pago_efectivo, $pago_tarjeta, $numero_tarjeta, $tarjeta_habiente,
		$cambio, $estado, $idcliente, $idusuario);

		}

		public static function Insertar_DetalleVenta($idproducto, $cantidad, $precio_unitario, $exento, $descuento, $fecha_vence, $importe){

		$cmd = CotizacionModel::Insertar_DetalleVenta($idproducto, $cantidad, $precio_unitario, $exento, $descuento, $fecha_vence, $importe);

		}

		public static function Imprimir_Ticket_DetalleVenta($idVenta){

			$filas = CotizacionModel::Imprimir_Ticket_DetalleVenta($idVenta);
			return $filas;

		}

		public static function Imprimir_Ticket_Venta($idVenta){

			$filas = CotizacionModel::Imprimir_Ticket_Venta($idVenta);
			return $filas;

		}

		public static function Imprimir_Ticket_Cli($p_idcliente){

			$filas = CotizacionModel::Imprimir_Ticket_Cli($p_idcliente);
			return $filas;

		}

		public static function Ver_idproducto($idCotizacion){

		$cmd = CotizacionModel::Ver_idproducto($idCotizacion);

		}

		}


 ?>
