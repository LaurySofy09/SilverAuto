<?php 

	spl_autoload_register(function($className){
		$model = "../../model/". $className ."_model.php";
		$controller = "../../controller/". $className ."_controller.php";
	
		require_once($model);
		require_once($controller);
	});

	$funcion = new Empleado();

	if(isset($_POST['nombre_empleado']) && isset($_POST['apellido_empleado'])){
		
		try {


			$proceso = $_POST['proceso'];
			$id = $_POST['id'];
			$nombre_empleado = trim($_POST['nombre_empleado']);
			$apellido_empleado = trim($_POST['apellido_empleado']);
			$telefono_empleado = trim($_POST['telefono_empleado']);
			$email_empleado = trim($_POST['email_empleado']);
			$estado = trim($_POST['estado']);

			$telefono_empleado = str_replace ( "-", "", $telefono_empleado);
			$imagen = trim($_POST["imagen"]);
			$cimagen = trim($_POST["cimagen"]);
			
			if($imagen == ''){$imagen = "";}
			if($cimagen == ''){$cimagen = "";}
			switch($proceso){

			case 'Registro':
				$funcion->Insertar_Empleado($nombre_empleado,$apellido_empleado,$telefono_empleado,$email_empleado,$imagen);
			break;

			case 'Edicion':
				$funcion->Editar_Empleado($id,$nombre_empleado,$apellido_empleado,$telefono_empleado,$email_empleado,$estado, $imagen,$cimagen);
			break;

			default:
				$data = "Error";
 	   		 	echo json_encode($data);
			break;
		}
			
		} catch (Exception $e) {
			
			$data = "Error";
 	   		echo json_encode($data);
		}

	}
	
	

  	

?>
