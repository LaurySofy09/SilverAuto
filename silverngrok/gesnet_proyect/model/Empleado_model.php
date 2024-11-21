<?php 

	require_once('Conexion.php');

	class EmpleadoModel extends Conexion
	{
		public static function Listar_Empleados()
		{
			$dbconec = Conexion::Conectar();

			try 
			{
				$query = "CALL sp_view_empleado();";
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

		public static function Insertar_Empleado($nombre_empleado, $apellido_empleado, $telefono_empleado, $email_empleado,$imagen)
		{
			$dbconec = Conexion::Conectar();
			try 
			{
				function format_uri( $string, $separator = '-' )
			  {
				$accents_regex = '~&([a-z]{1,2})(?:acute|cedil|circ|grave|lig|orn|ring|slash|th|tilde|uml);~i';
				$special_cases = array( '&' => 'and', "'" => '');
				$string = mb_strtolower( trim( $string ), 'UTF-8' );
				$string = str_replace( array_keys($special_cases), array_values( $special_cases), $string );
				$string = preg_replace( $accents_regex, '$1', htmlentities( $string, ENT_QUOTES, 'UTF-8' ) );
				$string = preg_replace("/[^a-z0-9]/u", "$separator", $string);
				$string = preg_replace("/[$separator]+/u", "$separator", $string);
				return $string;
			  }
				if ($imagen!="") {
				  $textura = $imagen; 
				  $iFileType = pathinfo($textura,PATHINFO_EXTENSION);
				  $file_array2 = explode(".", $textura);
				  $limpia=format_uri($file_array2[0]);
				  $imagen = $limpia.'.'.$iFileType;
				  }
				$query = "CALL sp_insert_empleado(:nombre_empleado, :apellido_empleado, :telefono_empleado, :email_empleado, :imagen)";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":nombre_empleado",$nombre_empleado);
				$stmt->bindParam(":apellido_empleado",$apellido_empleado);
				$stmt->bindParam(":telefono_empleado",$telefono_empleado);
				$stmt->bindParam(":email_empleado",$email_empleado);
				$stmt->bindParam(":imagen",$imagen);

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

					$data = "Error_Empleado";
 	   		 	 	echo json_encode($data);
				}
				$dbconec = null;
			} catch (Exception $e) {
				$data = "Error_Empleado";
				echo json_encode($data);
				
			}

		}

		public static function Editar_Empleado($idempleado, $nombre_empleado, $apellido_empleado, $telefono_empleado, $email_empleado, $estado,$imagen,$cimagen)
		{
			$dbconec = Conexion::Conectar();
			try 
			{
				function format_uri( $string, $separator = '-' )
				{
				  $accents_regex = '~&([a-z]{1,2})(?:acute|cedil|circ|grave|lig|orn|ring|slash|th|tilde|uml);~i';
				  $special_cases = array( '&' => 'and', "'" => '');
				  $string = mb_strtolower( trim( $string ), 'UTF-8' );
				  $string = str_replace( array_keys($special_cases), array_values( $special_cases), $string );
				  $string = preg_replace( $accents_regex, '$1', htmlentities( $string, ENT_QUOTES, 'UTF-8' ) );
				  $string = preg_replace("/[^a-z0-9]/u", "$separator", $string);
				  $string = preg_replace("/[$separator]+/u", "$separator", $string);
				  return $string;
				}
				
				if ($imagen!="") {
				  $textura = $imagen; 
				  $iFileType = pathinfo($textura,PATHINFO_EXTENSION);
				  $file_array2 = explode(".", $textura);
				  $limpia=format_uri($file_array2[0]);
				  $imagen = $limpia.'.'.$iFileType;
				  }elseif($cimagen!=""){
					 $imagen = $cimagen;
				 }else{
					$imagen = "";
					}
				$query = "CALL sp_update_empleado(:idempleado, :nombre_empleado, :apellido_empleado, :telefono_empleado, :email_empleado, :estado,:imagen);";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":idempleado",$idempleado);
				$stmt->bindParam(":nombre_empleado",$nombre_empleado);
				$stmt->bindParam(":apellido_empleado",$apellido_empleado);
				$stmt->bindParam(":telefono_empleado",$telefono_empleado);
				$stmt->bindParam(":email_empleado",$email_empleado);
				$stmt->bindParam(":estado",$estado);
				$stmt->bindParam(":imagen",$imagen);

				if($stmt->execute())
				{

				  $data = "Validado";
   				  echo json_encode($data);
				
				} else {

					$data = "Error_Empleado";
 	   		 	 	echo json_encode($data);
				}
				$dbconec = null;
			} catch (Exception $e) {
				$data = "Error_Empleado";
				echo json_encode($data);
			
			}

		}

	}


 ?>