<?php

	spl_autoload_register(function($className){
		$model = "../../model/". $className ."_model.php";
		$controller = "../../controller/". $className ."_controller.php";

		require_once($model);
		require_once($controller);
	});

	$funcion = new Proveedor();

	if(isset($_POST['nombre_proveedor']) && isset($_POST['numero_nit'])){

		try {


			$proceso = $_POST['proceso'];
			$id = $_POST['id'];
			$nombre_proveedor = trim($_POST['nombre_proveedor']);
			$numero_telefono = trim($_POST['numero_telefono']);
			$numero_nit = trim($_POST['numero_nit']);
			$numero_nrc = trim($_POST['numero_nrc']);
			$nombre_contacto = trim($_POST['nombre_contacto']);
			$telefono_contacto = trim($_POST['telefono_contacto']);
			$estado = trim($_POST['estado']);
			$Correo = trim($_POST['Correo']);
			$Direccion = trim($_POST['Direccion']);
			$Comentario = trim($_POST['Comentario']);


			switch($proceso){

			case 'Registro':
				$funcion->Insertar_Proveedor($nombre_proveedor, $numero_telefono, $numero_nit, $numero_nrc,
				$nombre_contacto, $telefono_contacto, $Correo, $Direccion, $Comentario);
			break;

			case 'Edicion':
				$funcion->Editar_Proveedor($id,$nombre_proveedor, $numero_telefono, $numero_nit, $numero_nrc,
				$nombre_contacto, $telefono_contacto, $estado, $Correo, $Direccion, $Comentario);
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
