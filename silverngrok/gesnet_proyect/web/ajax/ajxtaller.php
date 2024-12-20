<?php

	spl_autoload_register(function($className){
		$model = "../../model/". $className ."_model.php";
		$controller = "../../controller/". $className ."_controller.php";

		require_once($model);
		require_once($controller);
	});

	$funcion = new Taller();

if (!empty($_GET)){
  $criterio = isset($_GET['criterio']) ? $_GET['criterio'] : '';

  if($criterio == "max"){
    $funcion->Ver_Max_Orden();

  }
}

if (!empty($_POST))
{
	if(isset($_POST['proceso'])){

		try {

			$proceso = $_POST['proceso'];

			switch($proceso){

			case 'detalleOrden':
				$idorden  =  $_POST['idorden'];
				echo $funcion->ConsultarDetalle_OrdenTaller($idorden); 
			break;

			case 'deleteDetalle':
				$iddetalle  =  $_POST['iddetalle'];
				$idproducto  =  $_POST['idproducto'];
				$cantidad  =  $_POST['cantidad'];
				echo $funcion->EliminarDetalleOrden($iddetalle, $idproducto, $cantidad); 
			break;
			
			case 'Informacion':

				$idcliente  =  $_POST['cliente'];
				$idtecnico =  $_POST['tecnico'];
				$aparato = $_POST['aparato'];
				$idmarca  = $_POST['marca'];
				$modelo  = $_POST['modelo'];
				$serie  = $_POST['serie'];
				$averia  = $_POST['averia'];
				$observaciones  =  $_POST['observaciones'];
				$deposito_revision  =  $_POST['deposito_revision'];
				$deposito_reparacion  =  $_POST['deposito_reparacion'];
				$parcial_pagar =  $_POST['parcial'];
                $Repuesto =  $_POST['Repuesto'];
                $ManoObra =  $_POST['ManoObra'];
                $HoraObra =  $_POST['HoraObra'];
                $AnioAuto =  $_POST['AnioAuto'];
                //$Cedula =  $_POST['Cedula'];
                    
				$funcion->Insertar_Orden($idcliente,$aparato,$modelo,$idmarca,$serie,$idtecnico,$averia,
        $observaciones,$deposito_revision,$deposito_reparacion,$parcial_pagar, $Repuesto, $ManoObra, $HoraObra, $AnioAuto);

			break;
						

			case 'Editar-Informacion':

				$idorden = $_POST['id'];
				$numero_orden = $_POST['numero_orden'];
				//$fecha_ingreso = $_POST['fecha_ingreso'];
				$idcliente  =  $_POST['cliente'];
				$idtecnico =  $_POST['tecnico'];
				$aparato = $_POST['aparato'];
				$idmarca  = $_POST['marca'];
				$modelo  = $_POST['modelo'];
				$Placa  = $_POST['serie'];
				$averia  = $_POST['averia'];
				$observaciones  =  $_POST['observaciones'];
				$deposito_revision  =  $_POST['deposito_revision'];
				$deposito_reparacion  =  $_POST['deposito_reparacion'];
                $Repuesto =  $_POST['Repuesto'];
                $ManoObra =  $_POST['ManoObra'];
                $HoraObra =  $_POST['HoraObra'];
                $AnioAuto =  $_POST['AnioAuto'];
        /*$fecha_ingreso = DateTime::createFromFormat('d/m/Y H:i:s',$fecha_ingreso)->format('Y-m-d H:i:s');*/


				$funcion->Editar_Orden($idorden,$numero_orden,$idcliente,$aparato,$modelo,$idmarca,$Placa,$idtecnico,$averia,
				$observaciones,$deposito_revision,$deposito_reparacion, $Repuesto, $ManoObra, $HoraObra, $AnioAuto);

			break;



			case 'Diagnostico':

				$idorden  =  $_POST['id'];
				$diagnostico  =  $_POST['diagnostico'];
				$estado_aparato  =  $_POST['estado'];
				$repuestos  =  $_POST['repuestos'];
				$mano_obra  =  $_POST['mano_obra'];
				$fecha_alta  = $_POST['fecha_alta'];
				$fecha_retiro = $_POST['fecha_retiro'];
				$ubicacion  =  $_POST['ubicacion'];
				$parcial_pagar =  $_POST['parcial'];
				$HoraObra =  $_POST['HoraObra'];
				$fecha_alta = DateTime::createFromFormat('d/m/Y H:i:s',$fecha_alta)->format('Y-m-d H:i:s');
				if($fecha_retiro == ''){
					$funcion->Insertar_Diagnostico($idorden,$diagnostico,$estado_aparato,$repuestos,$mano_obra,$fecha_alta,NULL,
		    		$ubicacion,$parcial_pagar, $HoraObra);
				} else {
					$fecha_retiro = DateTime::createFromFormat('d/m/Y H:i:s',$fecha_retiro)->format('Y-m-d H:i:s');
					$funcion->Insertar_Diagnostico($idorden,$diagnostico,$estado_aparato,$repuestos,$mano_obra,$fecha_alta,$fecha_retiro,
		    		$ubicacion,$parcial_pagar, $HoraObra);
				}

			break;


			case 'Edicion':

				$id = $_POST['id'];
				$numero_orden = $_POST['numero_orden'];
				$fecha_ingreso = $_POST['fecha_ingreso'];
				$fecha_alta  = $_POST['fecha_alta'];
				$fecha_retiro = $_POST['fecha_retiro'];
				$idcliente  =  $_POST['cliente'];
				$idtecnico =  $_POST['tecnico'];
				$aparato = $_POST['aparato'];
				$idmarca  = $_POST['marca'];
				$modelo  = $_POST['modelo'];
				$serie  = $_POST['serie'];
				$averia  = $_POST['averia'];
				$observaciones  =  $_POST['observaciones'];
				$diagnostico  =  $_POST['diagnostico'];
				$estado_aparato  =  $_POST['estado'];
				$deposito_revision  =  $_POST['deposito_revision'];
				$deposito_reparacion  =  $_POST['deposito_reparacion'];
				$repuestos  =  $_POST['repuestos'];
				$mano_obra  =  $_POST['mano_obra'];
				$parcial_pagar =  $_POST['parcial'];
				$ubicacion  =  $_POST['ubicacion'];

        $fecha_ingreso = DateTime::createFromFormat('d/m/Y H:i:s',$fecha_ingreso)->format('Y-m-d H:i:s');
        $fecha_alta = DateTime::createFromFormat('d/m/Y H:i:s',$fecha_alta)->format('Y-m-d H:i:s');
        $fecha_retiro = DateTime::createFromFormat('d/m/Y H:i:s',$fecha_retiro)->format('Y-m-d H:i:s');

				$funcion->Editar_Orden($id,$numero_orden,$fecha_ingreso,$idcliente,$aparato,$modelo,$idmarca,$serie,$idtecnico,$averia,
		    $observaciones,$deposito_revision,$deposito_reparacion,$diagnostico,$estado_aparato,$repuestos,$mano_obra,$fecha_alta,$fecha_retiro,
		    $ubicacion,$parcial_pagar);
			break;

			case 'Borrar':

				$numero_transaccion  =  $_POST['numero_transaccion'];
				$funcion->Borrar_Orden($numero_transaccion);

			break;

			default:
				$data = "Error";
 	   		 	echo json_encode($data);
			break;
		}

		} catch (Exception $e) {
       $data = "Error ajxtaller";
	     error_log("Error ajxtaller: " . $e->getMessage());
       echo json_encode($e->getMessage());
    }

	}
	else{
		try{
		    if(isset($_POST['cart'])){
			$cartItems = $_POST['cart'];
			$respuesta = "";
			echo $funcion->InsertDetalleOrdenTaller($cartItems);
		    }
			
		}
		catch(Exception $e)
		{
		 $data = "Error ajxtaller";
	     error_log("Error ajxtaller: " . $e->getMessage());
         echo json_encode($e->getMessage());			
		}
		
	}

}


?>
