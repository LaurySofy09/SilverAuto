<?php 
	session_start();
	require_once('Conexion.php');

	class LoginModel extends Conexion
	{

		public static function Restaurar_Password($usuario,$contrasena)
		{
			$dbconec = Conexion::Conectar();
			try 
			{
				$query = "CALL sp_reset_password_usuario(:usuario,:contrasena)";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":usuario",$usuario);
				$stmt->bindParam(":contrasena",$contrasena);

				if($stmt->execute())
				{
					$data = "Validado";
	   				echo json_encode($data);
					
				} else {

					$data = "Error_Login";
 	   		 	 	echo json_encode($data);
				}

				$dbconec = null;
			} catch (Exception $e) {
				$data = "Error_Login";
				echo json_encode($data);
				
			}

		}

		
		public static function Login_Usuario($usuario,$contrasena)
		{
			$dbconec = Conexion::Conectar();

			try 
			{

				$query = "SELECT * FROM usuario where usuario = :usuario";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":usuario",$usuario);

				if($stmt->execute())
				{
					$row = $stmt->fetch(PDO::FETCH_ASSOC);

					/*if($row['contrasena'] == $contrasena){*/
					if ($row && password_verify($contrasena, $row['contrasena'])){
						$stmt2 = $dbconec->prepare("SELECT * FROM empleado WHERE idempleado = ?");
						$stmt2->execute([$row['idempleado']]);
						$user = $stmt2->fetch();

						$_SESSION['user_id'] = $row['idusuario'];
						$_SESSION['user_name'] = $row['usuario'];
						$_SESSION['user_tipo'] = $row['tipo_usuario'];
						$_SESSION['user_empleado'] = $user['nombre_empleado'];

					   $data = "Validado";
					   echo json_encode($data);

					} else {

						$data = "Bad Pass";
						echo json_encode($data);
					}

				}

			}  catch (Exception $e) {
				$data = "Error_Login";
				echo json_encode($data);
			
			}
						

		}


}

 ?>