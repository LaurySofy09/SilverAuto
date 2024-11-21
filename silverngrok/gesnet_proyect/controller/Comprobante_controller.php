<?php 

	class Comprobante {

		public static function Listar_Comprobantes(){

			$filas = ComprobanteModel::Listar_Comprobantes();
			return $filas;
		
		}

		public static function Insertar_Comprobante($comprobante){

			$cmd = ComprobanteModel::Insertar_Comprobante($comprobante);
			
		}

		public static function Editar_Comprobante($idcomprobante,$comprobante,$estado){

			$cmd = ComprobanteModel::Editar_Comprobante($idcomprobante,$comprobante,$estado);
			
		}

	}


 ?>