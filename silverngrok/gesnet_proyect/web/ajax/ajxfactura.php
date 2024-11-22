<?php 
// Iniciar la sesión
session_start();

spl_autoload_register(function($className){
    $model = "../../model/Factura_model.php";
    //$controller = "../../controller/". $className ."_controller.php";
    require_once($model);
   // require_once($controller);
});

$idUsuario = isset($_SESSION['user_id']) ? $_SESSION['user_id'] : 0;

$flagConsulta = isset($_POST['flagConsulta']) ? $_POST['flagConsulta'] : 0;

$hiddenIdv = isset($_POST['hiddenIdv']) ? $_POST['hiddenIdv'] : 0;

// Verifica los datos recibidos
error_log('flagConsulta: ' . $flagConsulta);

$funcion = new FacturaModel();
header('Content-Type: application/json');
if ($hiddenIdv == 0)
{
	if ($flagConsulta==1 || $flagConsulta ==0){
		   echo $funcion->ConsultarFacturas($flagConsulta); 
	}
	else{
		if ($flagConsulta==2){
			echo $funcion->ConsultarVentaCredito();
		}
	}
}
else
{
    try {
        $tipo_pago = $_POST['tipo_pago'];
        $comprobante = $_POST['comprobante'];
        $efectivo = trim($_POST['efectivo']);
        $pago_tarjeta = trim($_POST['pago_tarjeta']);
        $numero_tarjeta = trim($_POST['numero_tarjeta']);
        $tarjeta_habiente = trim($_POST['tarjeta_habiente']);
        $cambio = trim($_POST['cambio']);
		$pagado = trim($_POST['pagado']);

        if ($tipo_pago == '1') {
            $tipo_pago = 'EFECTIVO';
        } else if ($tipo_pago == '2') {
            $tipo_pago = 'TARJETA';
        } else if ($tipo_pago == '3') {
            $tipo_pago = 'EFECTIVO Y TARJETA';
        }

        echo $funcion->ActualizarVentaFact($hiddenIdv, $tipo_pago, $comprobante, $efectivo, $pago_tarjeta, $numero_tarjeta, $tarjeta_habiente, $cambio, $idUsuario, $pagado);
    } catch (Exception $e) {
        $data = "Error";
        echo json_encode($data);
    }
}
?>
