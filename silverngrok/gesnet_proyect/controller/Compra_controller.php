<?php

	class Compra {


			public static function Ver_Moneda_Reporte(){

				$filas = CompraModel::Ver_Moneda_Reporte();
				return $filas;

			}

		public static function Listar_Compras($criterio,$date,$date2,$estado,$pago){

			$filas = CompraModel::Listar_Compras($criterio,$date,$date2,$estado,$pago);
			return $filas;

		}

		public static function Listar_Compras_Detalle($criterio,$date,$date2,$estado,$pago){

			$filas = CompraModel::Listar_Compras_Detalle($criterio,$date,$date2,$estado,$pago);
			return $filas;

		}

		public static function Listar_Compras_Totales($criterio,$date,$date2,$estado,$pago){

			$filas = CompraModel::Listar_Compras_Totales($criterio,$date,$date2,$estado,$pago);
			return $filas;

		}

		public static function Listar_Detalle($idCompra){

			$filas = CompraModel::Listar_Detalle($idCompra);
			return $filas;

		}

		public static function Listar_Info($idCompra){

			$filas = CompraModel::Listar_Info($idCompra);
			return $filas;

		}

		public static function Listar_Historico($idproducto){

			$filas = CompraModel::Listar_Historico($idproducto);
			return $filas;

		}

		public static function Reporte_Historico($idproducto){

			$filas = CompraModel::Reporte_Historico($idproducto);
			return $filas;

		}

		public static function Reporte_Historico_Mas_Bajo($idproducto){

			$filas = CompraModel::Reporte_Historico_Mas_Bajo($idproducto);
			return $filas;

		}

		public static function Count_Compras($criterio,$date,$date2){

			$filas = CompraModel::Count_Compras($criterio,$date,$date2);
			return $filas;

		}

		public static function Insertar_Compra($fecha_compra, $idproveedor, $tipo_pago, $numero_comprobante, $tipo_comprobante, $fecha_comprobante,
		$sumas, $iva, $exento, $retenido, $total, $sonletras){

		$cmd = CompraModel::Insertar_Compra($fecha_compra, $idproveedor, $tipo_pago, $numero_comprobante, $tipo_comprobante, $fecha_comprobante,
		$sumas, $iva, $exento, $retenido, $total, $sonletras);

		}

		public static function Insertar_DetalleCompra($idproducto, $cantidad, $precio_unitario, $exento, $fecha_vence, $importe){

		$cmd = CompraModel::Insertar_DetalleCompra($idproducto, $cantidad, $precio_unitario, $exento, $fecha_vence, $importe);

		}


		public static function Anular_Compra($idcompra){

		$cmd = CompraModel::Anular_Compra($idcompra);

		}

	}


 ?>
