<?php 

	require_once('Conexion.php');

	class ComprobanteModel extends Conexion
	{
		public static function Listar_Comprobantes()
		{
			$dbconec = Conexion::Conectar();

			try 
			{
				$query = "CALL sp_view_comprobante();";
				$stmt = $dbconec->prepare($query);
				$stmt->execute();
				$count = $stmt->rowCount();

				if($count > 0)
				{
					return $stmt->fetchAll();
				}

				
				$dbconec = null;
			} catch (Exception $e) {
				
				echo '<span class="label label-danger label-block">ERROR AL CARGAR LOS DATOS, PRESIONE F5</span>';
			}
		}

		public static function Insertar_comprobante($comprobante)
		{
			$dbconec = Conexion::Conectar();
			try 
			{
				$query = "CALL sp_insert_comprobante(:comprobante)";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":comprobante",$comprobante);

				if($stmt->execute())
				{
					$count = $stmt->rowCount();
					if($count == 0){
						$data = "Duplicado";
 	   					echo json_encode($data);
					} else {
						$data = "Validado";
 	   					echo json_encode($data);
					}
				} else {

					$data = "Error_Comprobante";
 	   		 	 	echo json_encode($data);
				}
				$dbconec = null;
			} catch (Exception $e) {
				$data = "Error_Comprobante";
				echo json_encode($data);
				
			}

		}

		public static function Editar_comprobante($idcomprobante,$comprobante,$estado)
		{
			$dbconec = Conexion::Conectar();
			try 
			{
				$query = "CALL sp_update_comprobante(:idcomprobante,:comprobante,:estado);";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":idcomprobante",$idcomprobante);
				$stmt->bindParam(":comprobante",$comprobante);
				$stmt->bindParam(":estado",$estado);


				if($stmt->execute())
				{

				  $data = "Validado";
   				  echo json_encode($data);
				
				} else {

					$data = "Error_Comprobante";
 	   		 	 	echo json_encode($data);
				}
				$dbconec = null;
			} catch (Exception $e) {
				$data = "Error_Comprobante";
				echo json_encode($data);
			
			}

		}

	}


 ?>