<?php
	require('ClassTicket.php');
	$idventa =  isset($_GET['venta']) ? $_GET['venta'] : '';
	try
	{

	spl_autoload_register(function($className){
            $model = "../model/". $className ."_model.php";
            $controller = "../controller/". $className ."_controller.php";

           require_once($model);
           require_once($controller);
	});


    $objVenta = new Venta();

    if($idventa == ""){
    	$detalle = $objVenta->Imprimir_Ticket_DetalleVenta('0');
    	echo $idventa;
    	$datos = $objVenta->Imprimir_Ticket_Venta('0');
    } else {
    	$detalle = $objVenta->Imprimir_Ticket_DetalleVenta($idventa);
    	$datos = $objVenta->Imprimir_Ticket_Venta($idventa);
    } 

    $p_idcliente = "";
    $p_nombre_cliente ="";
    $email = "";
    $numero_comprobante = "";
    foreach ($datos as $row => $column) {  	
		$p_idcliente = $column["p_idcliente"];
		$mcliente = $objVenta->Imprimir_Ticket_Cli($p_idcliente);
		$p_nombre_cliente = $mcliente["nombre_cliente"];
		$nit = $mcliente["numero_nit"];
		$fono = $mcliente["numero_telefono"];
		$email = $mcliente["email"];
    	$tipo_comprobante = $column["p_tipo_comprobante"];
    	$empresa = $column["p_empresa"];
    	$propietario = $column["p_propietario"];
    	$direccion = $column["p_direccion"];
    	$nit = $column["p_numero_nit"];
    	$nrc = $column["p_numero_nrc"];
    	$fecha_resolucion = $column["p_fecha_resolucion"];
    	$numero_resolucion = $column["p_numero_resolucion"];
    	$serie = $column["p_serie"];
    	$numero_comprobante = $column["p_numero_comprobante"];
    	$empleado = $column["p_empleado"];
    	$numero_venta = $column["p_numero_venta"];
    	$fecha_venta = $column["p_fecha_venta"];
    	$subtotal = $column["p_subtotal"];
    	$exento = $column["p_exento"];
    	$descuento = $column["p_descuento"];
    	$total = $column["p_total"];
    	$numero_productos = $column["p_numero_productos"];
		$tipo_pago = $column["p_tipo_pago"];
		$efectivo = $column["p_pago_efectivo"];
		$pago_tarjeta = $column["p_pago_tarjeta"];
		$numero_tarjeta = $column["p_numero_tarjeta"];
		$tarjeta_habiente = $column["p_tarjeta_habiente"];
		$cambio = $column["p_cambio"];
		$moneda = $column["p_moneda"];
		$estado = $column["p_estado"];
		$iva = $column["p_iva"];
    }

    
		$numero_tarjeta = substr($numero_tarjeta,0,4).'-XXXX-XXXX-'.substr($numero_tarjeta,12,16);

	$pdf = new TICKET('P','mm',array(76,297));
	$pdf->AddPage();


	if($tipo_comprobante == '1')
	{
		$pdf->SetFont('Arial', '', 12);
		$pdf->SetAutoPageBreak(true,1);

		include('../includes/ticketheader.inc.php');

		$pdf->SetFont('Arial', '', 9.2);
		$pdf->Text(2, $get_YH + 2 , '------------------------------------------------------------------');
		$pdf->SetFont('Arial', 'B', 8.5);
		$pdf->Text(3.8, $get_YH  + 5, 'Transc: '.$numero_venta);
		$pdf->Text(55, $get_YH + 5, 'Caja No.: 1');
		$pdf->Text(4, $get_YH + 10, 'Fecha : '.$fecha_venta);
		$pdf->Text(4, $get_YH + 15, 'No. Ticket : '.$numero_comprobante);
		$pdf->Text(38, $get_YH  + 15, 'Cajero : '.substr($empleado, 0,5));
		$pdf->SetFont('Arial', '', 9.2);
		//$pdf->Text(2, $get_YH + 18, '------------------------------------------------------------------');
		
		$pdf->SetFont('Arial', '', 9.2);
		//$pdf->Text(2, $get_YH + 2 , '------------------------------------------------------------------');
		$pdf->SetFont('Arial', 'B', 7.5);
		//$pdf->Text(3.8, $get_YH  + 5, 'Transc : '.$numero_venta);
		/*$pdf->Text(55, $get_YH + 20, 'NIT: '.$nit);*/
		$pdf->Text(4, $get_YH + 20, 'Nombre: '.$p_nombre_cliente);
		/*$pdf->Text(4, $get_YH + 25, 'Telefono : '.$fono);
		$pdf->Text(38, $get_YH  + 25, 'Email :'.$email);*/
		$pdf->SetFont('Arial', '', 9.2);
		$pdf->Text(2, $get_YH + 23, '------------------------------------------------------------------');
		
		$pdf->SetXY(2,$get_YH + 23);
		$pdf->SetFillColor(255,255,255);
		$pdf->SetFont('Arial','B',8.5);
		$pdf->Cell(7,4,'C.',0,0,'L',1);
		$pdf->Cell(42,4,'Descripcion',0,0,'L',1);
		$pdf->Cell(10,4,'Precio',0,0,'L',1);
		$pdf->Cell(12,4,'Total',0,0,'R',1);
		$pdf->SetFont('Arial','',8.5);
		$pdf->Text(2, $get_YH + 28, '-----------------------------------------------------------------------');
		$pdf->Ln(6);
		$item = 0;
		while($row = $detalle->fetch(PDO::FETCH_ASSOC)) {
		 $item = $item + 1;
			$pdf->setX(1.1);
			$x = $pdf->GetX();
			$y = $pdf->GetY();
			$pdf->SetFont('Arial','',7);
			$pdf->MultiCell(7,3,round($row['cantidad']),0,0,'L',1);
			$pdf->SetXY($x + 7, $y);
			$pdf->MultiCell(40,3,$row['descripcion'],0,0,'L',1);
			$pdf->SetXY($x + 50, $y);
			$pdf->MultiCell(10,3,$row['precio_unitario'],0,0,'L',1);
			$pdf->SetXY($x + 62, $y);
			$pdf->MultiCell(13,3,$row['importe'],0,0,'L',1);
			$pdf->Ln();
			$get_Y = $pdf->GetY();
		}
		$pdf->Text(2, $get_Y+1, '--------------------------------------------------------------------------------------');
		$pdf->SetFont('Arial','B',8.5);
		$pdf->Text(4,$get_Y + 5,'G = GRAVADO');
		$pdf->Text(30,$get_Y + 5,'E = EXENTO');

		$pdf->Text(4,$get_Y + 10,'SUBTOTAL :');
		$pdf->Text(57,$get_Y + 10,$subtotal);
		$pdf->Text(4,$get_Y + 15,'EXENTO :');
		$pdf->Text(57,$get_Y + 15,$exento);
		$pdf->Text(4,$get_Y + 20,'GRAVADO :');
		$pdf->Text(57,$get_Y + 20,$iva);
		$pdf->Text(4,$get_Y + 25,'DESCUENTO :');
		$pdf->Text(56,$get_Y + 25,'-'.$descuento);
		$pdf->Text(4,$get_Y + 30,'TOTAL A PAGAR :');
		$pdf->SetFont('Arial','B',8.5);
		$pdf->Text(57,$get_Y + 30,$total);

		$pdf->Text(2, $get_Y+33, '-----------------------------------------------------------------------');
		$pdf->Text(4,$get_Y + 36,'Numero de Productos :');
		$pdf->Text(57,$get_Y + 36,$numero_productos);

		if($tipo_pago == 'EFECTIVO'){

		$pdf->Text(24,$get_Y + 40,'Efectivo :');
		$pdf->Text(57,$get_Y + 40,$efectivo);
		$pdf->Text(24,$get_Y + 44,'Cambio :');
		$pdf->Text(57,$get_Y + 44,$cambio);


		$pdf->Text(2, $get_Y+47, '-----------------------------------------------------------------------');
		$pdf->SetFont('Arial','BI',8.5);
		$pdf->Text(3, $get_Y+52, 'Precios en : '.$moneda);
		if($estado == '2'):
			$pdf->Text(3, $get_Y+55, 'Esta venta ha sido al credito');
			$pdf->SetFont('Arial','B',8.5);
		endif;
		$pdf->SetFont('Arial','B',8.5);
		$pdf->Text(19, $get_Y+62, 'GRACIAS POR SU COMPRA');
		$pdf->SetFillColor(0,0,0);
		$pdf->Code39(9,$get_Y+64,$numero_venta,1,5);
		$pdf->Text(28, $get_Y+74, '*'.$numero_venta.'*');

	} else if ($tipo_pago == 'TARJETA'){

		$pdf->Text(20,$get_Y + 40.5,'No. Tarjeta :');
		$pdf->Text(40,$get_Y + 40.5,$numero_tarjeta);
		$pdf->Text(23,$get_Y + 45,'Debitado :');
		$pdf->Text(57,$get_Y + 45,$total);

		$pdf->Text(2, $get_Y+47, '-----------------------------------------------------------------------');
		$pdf->SetFont('Arial','BI',8.5);
		$pdf->Text(3, $get_Y+52, 'Precios en : '.$moneda);
		$pdf->SetFont('Arial','B',8.5);
		if($estado == '2'):
			$pdf->Text(3, $get_Y+55, 'Esta venta ha sido al credito');
			$pdf->SetFont('Arial','B',8.5);
		endif;
		$pdf->Text(19, $get_Y+62, 'GRACIAS POR SU COMPRA');
		$pdf->SetFillColor(0,0,0);
		$pdf->Code39(9,$get_Y+64,$numero_venta,1,5);
		$pdf->Text(28, $get_Y+74, '*'.$numero_venta.'*');

	} else if ($tipo_pago == 'EFECTIVO Y TARJETA'){

		$pdf->Text(24,$get_Y + 41,'Efectivo :');
		$pdf->Text(57,$get_Y + 41,$efectivo);

		$pdf->Text(20,$get_Y + 46,'No. Tarjeta :');
		$pdf->Text(40,$get_Y + 46,$numero_tarjeta);
		$pdf->Text(23,$get_Y + 51,'Debitado :');
		$pdf->Text(57,$get_Y + 51,$pago_tarjeta);

		$pdf->Text(2, $get_Y+53, '-----------------------------------------------------------------------');
		$pdf->SetFont('Arial','BI',8.5);
		$pdf->Text(3, $get_Y+58, 'Precios en : '.$moneda);
		$pdf->SetFont('Arial','',8.5);
		$pdf->Text(3, $get_Y+63, 'Venta realizada con dos metodos de pago');
		$pdf->SetFont('Arial','B',8.5);
		if($estado == '2'):
			$pdf->Text(3, $get_Y+66, 'Esta venta ha sido al credito');
			$pdf->SetFont('Arial','B',8.5);
		endif;
		$pdf->Text(19, $get_Y+73, 'GRACIAS POR SU COMPRA');
		$pdf->SetFillColor(0,0,0);
		$pdf->Code39(9,$get_Y+75,$numero_venta,1,5);
		$pdf->Text(28, $get_Y+84, '*'.$numero_venta.'*');

	}

		//$pdf->IncludeJS("print('true');");

	} else if ($tipo_comprobante == '2') {

		$pdf = new FPDF('P', 'mm', 'Letter'); // Configura el tamaño de página a carta
		$pdf->AddPage();
		$pdf->SetFont('Arial', '', 12);
		$pdf->SetAutoPageBreak(true, 1);

		//function Header() {
        // Logo
        $pdf->Image(__DIR__ . '/../web/assets/images/logo_taller.png', 10, 10, 50); // Ajustar las coordenadas y dimensiones según sea necesario
        
        // Invoice text
        $pdf->SetFont('Arial', 'B', 14); // Tamaño de la fuente más pequeño
        $pdf->SetXY(140, 30); // Ajustar la posición más a la izquierda
        $pdf->Cell(40, 10, 'Invoice', 0, 1, 'C');

        $pdf->SetFont('Arial', 'B', 10);
        $pdf->Rect(10, 60, 100, 10); // Cuadro para "Facturar a"
        $pdf->Rect(10, 70, 100, 30); // Cuadro para el nombre del cliente
        $pdf->Rect(120, 40, 40, 5); // Cuadro para "Fecha"
        $pdf->Rect(160, 40, 40, 5); // Cuadro para "Factura #"
        $pdf->Rect(120, 45, 40, 10); // Cuadro para "Fecha"
        $pdf->Rect(160, 45, 40, 10); // Cuadro para "Factura #"
        $pdf->Rect(140, 100, 20, 10); // Cuadro para "Rep"
        $pdf->Rect(160, 100, 40, 10); // Cuadro para "JO"


        // Añade texto y valores para "Facturar a", nombre del cliente, "Rep" y "JO"
        $pdf->SetXY(10, 60);
        $pdf->Cell(100, 10, 'Facturar a:', 0, 1); // Añade el texto "Facturar a"
        $pdf->SetFont('Arial', '', 8.5);
        $pdf->SetXY(10, 70);
        $pdf->MultiCell(100, 10, $p_nombre_cliente, 0); // Añade el nombre del cliente
        $pdf->SetXY(120, 40);
        $pdf->Cell(40, 5, 'Fecha', 0, 0, 'C'); // Añade el texto "Fecha"
        $pdf->SetXY(160, 40);
        $pdf->Cell(40, 5, 'Factura #', 0, 1, 'C'); // Añade el texto "Factura #"
        $pdf->SetFont('Arial', '', 8.5);
        $pdf->SetXY(120, 45);
        $pdf->Cell(40, 10, $fecha_venta, 0, 0, 'C'); // Añade la fecha
        $pdf->SetXY(160, 45);
        $pdf->Cell(40, 10, $numero_comprobante, 0, 1, 'C'); // Añade el número de factura
        $pdf->SetFont('Arial', '', 8.5);
        $pdf->SetXY(125, 100);
        $pdf->Cell(50, 10, 'Rep', 0, 0, 'C'); // Añade "Rep"
        $pdf->SetFont('Arial', '', 8.5);
        $pdf->SetXY(170, 100);
        $pdf->Cell(20, 10, $empleado, 0, 0, 'C');


		$pdf->SetY(110); // Ajusta la posición Y según sea necesario para alinear con la línea inferior de los cuadros "Rep" y "JO"
    
	    // Añade la cabecera
	    $pdf->SetFont('Arial', 'B', 8.5);
	    $pdf->SetFillColor(255, 255, 255); // Fondo blanco
	    $pdf->Cell(30, 6, 'Cantidad', 1, 0, 'L', true);
	    $pdf->Cell(80, 6, 'Descripcion', 1, 0, 'L', true);
	    $pdf->Cell(40, 6, 'Precio x unidad', 1, 0, 'L', true);
	    $pdf->Cell(40, 6, 'Total', 1, 0, 'R', true);
	    $pdf->Ln();

		 // Añade los datos
	    $pdf->SetFont('Arial', '', 7);
	    while ($row = $detalle->fetch(PDO::FETCH_ASSOC)) {
	        $pdf->Cell(30, 6, round($row['cantidad']), 1, 0, 'L', true);
	        $pdf->Cell(80, 6, $row['descripcion'], 1, 0, 'L', true);
	        $pdf->Cell(40, 6, $row['precio_unitario'], 1, 0, 'L', true);
	        $pdf->Cell(40, 6, $row['importe'], 1, 0, 'R', true);
		    $pdf->Ln();
		    $get_Y = $pdf->GetY();
		}


		$pdf->SetFont('Arial', '', 7);
		$pdf->SetXY(10, 210); // Ajustar la posición según sea necesario
        $pdf->MultiCell(0, 4, utf8_decode("NO SE ACEPTAN CAMBIOS NI DEVOLUCIONES EN PIEZAS ELECTRICAS.\nNO SE ACEPTAN CAMBIOS NI DEVOLUCIONES EN PEDIDOS ESPECIALES.\nNO SE ACEPTAN CAMBIOS NI DEVOLUCIONES DESPUES DE 15 DIAS.\nPARA GARANTIAS, CAMBIOS Y DEVOLUCIONES, DEBE PRESENTAR FACTURA \nORIGINAL FIRMADA Y EN BUEN ESTADO.\nTODO CAMBIO DE PIEZA DEBE REALIZARSE ANTES DE 24 HORAS.\nNO SE RECIBEN PIEZAS CON EMPAQUE DAÑADO O SUCIO.\nREPUESTOS BIEN VENDIDOS NO TIENEN DEVOLUCION.\nPIEZAS MAL INSTALADAS NO TIENEN GARANTIA."));

        $pdf->SetFont('Arial', '', 8.5);
		$pdf->SetXY(10, 260); // Ajustar la posición según sea necesario
        $pdf->MultiCell(0, 4, "__________________________\nFirma del cliente");

		$pdf->Text(130, $get_Y + 90, 'SUBTOTAL');
		$pdf->Text(170, $get_Y + 90, 'B/.'.$subtotal);
		$pdf->Text(130, $get_Y + 95, 'EXENTO');
		$pdf->Text(170, $get_Y + 95, 'B/.'.$exento);
		$pdf->Text(130, $get_Y + 100, 'ITMBS(7%)');
		$pdf->Text(170, $get_Y + 100, 'B/.'.$iva);
		$pdf->Text(130, $get_Y + 105, 'DESCUENTO');
		$pdf->Text(170, $get_Y + 105, 'B/.'.'- '.$descuento);
		$pdf->SetFont('Arial', 'B', 8.5);
		$pdf->Text(130, $get_Y + 110, 'TOTAL A PAGAR');
		$pdf->SetFont('Arial', 'B', 8.5);
		$pdf->Text(170, $get_Y + 110, 'B/.'.$total);

		$pdf->Output();

		} else if ($tipo_comprobante == '3') {


				$pdf->SetFont('Arial', '', 12);
				$pdf->SetAutoPageBreak(true,1);

				include('../includes/ticketheader.inc.php');

				$pdf->SetFont('Arial', '', 9.2);
				$pdf->Text(2, $get_YH + 2 , '------------------------------------------------------------------');
				$pdf->SetFont('Arial', 'B', 8.5);
				$pdf->Text(3.8, $get_YH  + 5, 'Transc : '.$numero_venta);
				$pdf->Text(55, $get_YH + 5, 'Caja No.: 1');
				$pdf->Text(4, $get_YH + 10, 'Fecha : '.$fecha_venta);
				$pdf->Text(4, $get_YH + 15, 'No. Boleta : '.$numero_comprobante);
				$pdf->Text(38, $get_YH  + 15, 'Cajero : '.substr($empleado, 0,5));
				$pdf->SetFont('Arial', '', 9.2);
				$pdf->Text(2, $get_YH + 18, '------------------------------------------------------------------');

				$pdf->SetXY(2,$get_YH + 19);
				$pdf->SetFillColor(255,255,255);
				$pdf->SetFont('Arial','B',8.5);
				$pdf->Cell(13,4,'Cantid',0,0,'L',1);
				$pdf->Cell(28,4,'Descripcion',0,0,'L',1);
				$pdf->Cell(16,4,'Precio',0,0,'L',1);
				$pdf->Cell(12,4,'Total',0,0,'L',1);
				$pdf->SetFont('Arial','',8.5);
				$pdf->Text(2, $get_YH + 24, '-----------------------------------------------------------------------');
				$pdf->Ln(6);
				$item = 0;
				while($row = $detalle->fetch(PDO::FETCH_ASSOC)) {
				 $item = $item + 1;
					$pdf->setX(1.1);
					$pdf->Cell(13,4,$row['cantidad'],0,0,'L');
					$pdf->Cell(28,4,$row['descripcion'],0,0,'L',1);
					$pdf->Cell(16,4,$row['precio_unitario'],0,0,'L',1);
					$pdf->Cell(8,4,$row['importe'],0,0,'L',1);
					$pdf->Ln(4.5);
					$get_Y = $pdf->GetY();
				}
				$pdf->Text(2, $get_Y+1, '-----------------------------------------------------------------------');
				$pdf->SetFont('Arial','B',8.5);
				$pdf->Text(4,$get_Y + 5,'G = GRAVADO');
				$pdf->Text(30,$get_Y + 5,'E = EXENTO');

				$pdf->Text(4,$get_Y + 10,'SUBTOTAL :');
				$pdf->Text(57,$get_Y + 10,$subtotal);
				$pdf->Text(4,$get_Y + 15,'EXENTO :');
				$pdf->Text(57,$get_Y + 15,$exento);
				$pdf->Text(4,$get_Y + 20,'GRAVADO :');
				$pdf->Text(57,$get_Y + 20,$subtotal);
				$pdf->Text(4,$get_Y + 25,'DESCUENTO :');
				$pdf->Text(56,$get_Y + 25,'-'.$descuento);
				$pdf->Text(4,$get_Y + 30,'TOTAL A PAGAR :');
				$pdf->SetFont('Arial','B',8.5);
				$pdf->Text(57,$get_Y + 30,$total);

				$pdf->Text(2, $get_Y+33, '-----------------------------------------------------------------------');
				$pdf->Text(4,$get_Y + 36,'Numero de Productos :');
				$pdf->Text(57,$get_Y + 36,$numero_productos);

				if($tipo_pago == 'EFECTIVO'){

				$pdf->Text(24,$get_Y + 40,'Efectivo :');
				$pdf->Text(57,$get_Y + 40,$efectivo);
				$pdf->Text(24,$get_Y + 44,'Cambio :');
				$pdf->Text(57,$get_Y + 44,$cambio);


				$pdf->Text(2, $get_Y+47, '-----------------------------------------------------------------------');
				$pdf->SetFont('Arial','BI',8.5);
				$pdf->Text(3, $get_Y+52, 'Precios en : '.$moneda);
				if($estado == '2'):
					$pdf->Text(3, $get_Y+55, 'Esta venta ha sido al credito');
					$pdf->SetFont('Arial','B',8.5);
				endif;
				$pdf->SetFont('Arial','B',8.5);
				$pdf->Text(19, $get_Y+62, 'GRACIAS POR SU COMPRA');
				$pdf->SetFillColor(0,0,0);
				$pdf->Code39(9,$get_Y+64,$numero_venta,1,5);
				$pdf->Text(28, $get_Y+74, '*'.$numero_venta.'*');

			} else if ($tipo_pago == 'TARJETA'){

				$pdf->Text(20,$get_Y + 40.5,'No. Tarjeta :');
				$pdf->Text(40,$get_Y + 40.5,$numero_tarjeta);
				$pdf->Text(23,$get_Y + 45,'Debitado :');
				$pdf->Text(57,$get_Y + 45,$total);

				$pdf->Text(2, $get_Y+47, '-----------------------------------------------------------------------');
				$pdf->SetFont('Arial','BI',8.5);
				$pdf->Text(3, $get_Y+52, 'Precios en : '.$moneda);
				$pdf->SetFont('Arial','B',8.5);
				if($estado == '2'):
					$pdf->Text(3, $get_Y+55, 'Esta venta ha sido al credito');
					$pdf->SetFont('Arial','B',8.5);
				endif;
				$pdf->Text(19, $get_Y+62, 'GRACIAS POR SU COMPRA');
				$pdf->SetFillColor(0,0,0);
				$pdf->Code39(9,$get_Y+64,$numero_venta,1,5);
				$pdf->Text(28, $get_Y+74, '*'.$numero_venta.'*');

			} else if ($tipo_pago == 'EFECTIVO Y TARJETA'){

				$pdf->Text(24,$get_Y + 41,'Efectivo :');
				$pdf->Text(57,$get_Y + 41,$efectivo);

				$pdf->Text(20,$get_Y + 46,'No. Tarjeta :');
				$pdf->Text(40,$get_Y + 46,$numero_tarjeta);
				$pdf->Text(23,$get_Y + 51,'Debitado :');
				$pdf->Text(57,$get_Y + 51,$pago_tarjeta);

				$pdf->Text(2, $get_Y+53, '-----------------------------------------------------------------------');
				$pdf->SetFont('Arial','BI',8.5);
				$pdf->Text(3, $get_Y+58, 'Precios en : '.$moneda);
				$pdf->SetFont('Arial','',8.5);
				$pdf->Text(3, $get_Y+63, 'Venta realizada con dos metodos de pago');
				$pdf->SetFont('Arial','B',8.5);
				if($estado == '2'):
					$pdf->Text(3, $get_Y+66, 'Esta venta ha sido al credito');
					$pdf->SetFont('Arial','B',8.5);
				endif;
				$pdf->Text(19, $get_Y+73, 'GRACIAS POR SU COMPRA');
				$pdf->SetFillColor(0,0,0);
				$pdf->Code39(9,$get_Y+75,$numero_venta,1,5);
				$pdf->Text(28, $get_Y+84, '*'.$numero_venta.'*');

			}
		}

$nombreArchivoPDF = 'Factura_'.$p_idcliente.'_'.$numero_comprobante.'.pdf'; // Puedes cambiar este nombre
$rutaDirectorio = __DIR__ . '/Tickets/';
$rutaCompletaPDF = $rutaDirectorio . $nombreArchivoPDF;
// Crear el directorio si no existe
if (!file_exists($rutaDirectorio)) {
    mkdir($rutaDirectorio, 0777, true);
}
// Guardar el PDF en la carpeta
$pdf->Output('F', $rutaCompletaPDF);

		session_start();

		// //Obtener el contenido del PDF en formato de cadena
		// // Obtener el contenido del PDF en formato de cadena
		// $pdf_content = $pdf->Output('', 'S');

		// // Codificar en Base64
		// $pdf_base64 = base64_encode($pdf_content);

		// Almacenar el contenido del PDF en la sesión
		//$_SESSION['pdf_content'] = chunk_split($pdf_base64);
		// Almacenar el contenido del PDF en la sesión
		$_SESSION['nombreArchivoPDF'] = $nombreArchivoPDF;
		$_SESSION['p_idcliente'] = $p_idcliente;
		$_SESSION['p_nombre_cliente'] = $p_nombre_cliente;
		$_SESSION['p_email'] = $email;
		$_SESSION['numero_comprobante'] = $numero_comprobante;
		
		 // Datos del correo
		/*$to = $email;
		$subject = 'Comprobante Silverauto #' . $numero_comprobante;
		$message = 'Gracias por preferirnos. </br> Este es un correo automático, no responda a este mensaje';
		$header = "From: Silverauto\r\n";
		$headers = "MIME-Version: 1.0" . "\r\n";
		$headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";
		
		$retval = mail ($to,$subject,$message,$header);
		if(!$retval) {
			
		}*/
		
		// Mostrar el PDF en una pestaña del navegador
		header('Content-Type: application/pdf');
		header('Content-Disposition: inline; filename="'.$nombreArchivoPDF.'"');

		// Usa readfile para enviar el contenido del archivo
		readfile($rutaCompletaPDF);
	} catch (Exception $e) {

		$pdf->Text(22.8, 5, 'ERROR AL IMPRIMIR TICKET error: ', $e);
		$pdf->Output('I','Ticket_ERROR.pdf',true);

	}








 ?>
