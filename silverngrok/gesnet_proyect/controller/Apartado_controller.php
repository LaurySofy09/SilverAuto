<?php

	class Apartado {

		public static function Ver_Moneda_Reporte(){

			$filas = ApartadoModel::Ver_Moneda_Reporte();
			return $filas;

		}

		public static function Listar_Apartados($criterio,$date,$date2,$estado){

			$filas = ApartadoModel::Listar_Apartados($criterio,$date,$date2,$estado);
			return $filas;

		}

		public static function Listar_Apartados_Totales($criterio,$date,$date2,$estado){

			$filas = ApartadoModel::Listar_Apartados_Totales($criterio,$date,$date2,$estado);
			return $filas;

		}

		public static function Listar_Apartados_Detalle($criterio,$date,$date2,$estado){

			$filas = ApartadoModel::Listar_Apartados_Detalle($criterio,$date,$date2,$estado);
			return $filas;

		}

		public static function Imprimir_Ticket_DetalleApartado($idApartado){

			$filas = ApartadoModel::Imprimir_Ticket_DetalleApartado($idApartado);
			return $filas;

		}

		public static function Imprimir_Ticket_Apartado($idApartado){

			$filas = ApartadoModel::Imprimir_Ticket_Apartado($idApartado);
			return $filas;

		}



		public static function Listar_Detalle($idApartado){

			$filas = ApartadoModel::Listar_Detalle($idApartado);
			return $filas;

		}

		public static function Listar_Info($idApartado){

			$filas = ApartadoModel::Listar_Info($idApartado);
			return $filas;

		}

		public static function Count_Apartados($criterio,$date,$date2){

			$filas = ApartadoModel::Count_Apartados($criterio,$date,$date2);
			return $filas;

		}


		public static function Listar_Clientes(){

			$filas = ApartadoModel::Listar_Clientes();
			return $filas;

		}

		public static function Listar_Comprobantes(){

			$filas = ApartadoModel::Listar_Comprobantes();
			return $filas;

		}


		public static function Autocomplete_Producto($search){

			$filas = ApartadoModel::Autocomplete_Producto($search);
			return $filas;

		}

		public static function Insertar_Apartado($fecha_limite_retiro,
		$sumas, $iva, $exento, $retenido, $descuento, $total, $abonado_apartado, $restante_pagar, $sonletras, $idcliente, $idusuario){

		$cmd = ApartadoModel::Insertar_Apartado($fecha_limite_retiro,
		$sumas, $iva, $exento, $retenido, $descuento, $total, $abonado_apartado, $restante_pagar, $sonletras, $idcliente, $idusuario);

		}

		public static function Insertar_Venta($idapartado,$tipo_pago, $tipo_comprobante,
		$pago_efectivo, $pago_tarjeta, $numero_tarjeta, $tarjeta_habiente,$cambio, $idcliente, $idusuario){

		$cmd = ApartadoModel::Insertar_Venta($idapartado,$tipo_pago, $tipo_comprobante,
		$pago_efectivo, $pago_tarjeta, $numero_tarjeta, $tarjeta_habiente,$cambio, $idcliente, $idusuario);

		}

		public static function Insertar_DetalleApartado($idproducto, $cantidad, $precio_unitario, $exento, $descuento, $fecha_vence, $importe){

		$cmd = ApartadoModel::Insertar_DetalleApartado($idproducto, $cantidad, $precio_unitario, $exento, $descuento, $fecha_vence, $importe);

		}

		public static function Anular_Apartado($idApartado){

		$cmd = ApartadoModel::Anular_Apartado($idApartado);

		}


	}


 ?>
