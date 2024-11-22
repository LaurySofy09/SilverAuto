<?php
	session_start();
	spl_autoload_register(function($className){
		$model = "../../model/". $className ."_model.php";
		$controller = "../../controller/". $className ."_controller.php";

		require_once($model);
		require_once($controller);
	});

	$funcion = new Producto();

	if(isset($_POST['nombre_producto']) && isset($_POST['precio_compra']) && isset($_POST['precio_venta'])){

		try {

			$proceso = $_POST['proceso'];
			$id = $_POST['id'];
			$codigo_barra = trim($_POST['codigo_barra']);
			$codigo_alternativo = trim($_POST['codigo_alternativo']);
			$nombre_producto = trim($_POST['nombre_producto']);
			$precio_compra = trim($_POST['precio_compra']);
			$precio_venta = trim($_POST['precio_venta']);
			$precio_venta1 = trim($_POST['precio_venta1']);
			$precio_venta2 = trim($_POST['precio_venta2']);
			$precio_venta3 = trim($_POST['precio_venta3']);
			$precio_venta_mayoreo = trim($_POST['precio_venta_mayoreo']);
			$stock = trim($_POST['stock']);
			$stock_min = trim($_POST['stock_min']);
			$idcategoria = trim($_POST['idcategoria']);
			$idmarca = trim($_POST['idmarca']);
			$idpresentacion = trim($_POST['idpresentacion']);
			$estado = trim($_POST['estado']);
			$exento = trim($_POST['exento']);
			$inventariable = trim($_POST['inventariable']);
			$perecedero = trim($_POST['perecedero']);
			//$imagen = $_FILES["imagen"]["tmp_name"];
			//$imagen = "po";
			
			$imagen = trim($_POST["imagen"]);
			$cimagen = trim($_POST["cimagen"]);
			if($idmarca == '')
			{
				$idmarca = NULL;
			}
			if($imagen == '')
			{
				$imagen = "";
			}
			if($cimagen == '')
			{
				$cimagen = "";
			}

			switch($proceso){

			case 'Registro':
				$funcion->Insertar_Producto($codigo_barra,$codigo_alternativo,$nombre_producto,$precio_compra,$precio_venta,$precio_venta1,$precio_venta2,$precio_venta3,$precio_venta_mayoreo,$stock,$stock_min,$idcategoria,$idmarca,$idpresentacion,$exento,$inventariable,$perecedero,$imagen,$_SESSION['user_id']);
				
			break;

			case 'Edicion':
				$funcion->Editar_Producto($id,$codigo_barra,$codigo_alternativo, $nombre_producto, $precio_compra, $precio_venta, $precio_venta1,$precio_venta2,$precio_venta3,$precio_venta_mayoreo, $stock_min, $idcategoria, $idmarca, $idpresentacion, $estado, $exento, $inventariable, $perecedero, $imagen,$cimagen,$_SESSION['user_id']);
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
