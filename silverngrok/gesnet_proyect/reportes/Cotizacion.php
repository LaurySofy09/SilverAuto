<?php
  require('fpdf/fpdf.php');
  $idcotizacion =  isset($_GET['cotizacion']) ? $_GET['cotizacion'] : '';

  try
  {
  spl_autoload_register(function($className){
            $model = "../model/". $className ."_model.php";
            $controller = "../controller/". $className ."_controller.php";

           require_once($model);
              require_once($controller);
  });

    $objCotizacion =  new Cotizacion();

    $listado = $objCotizacion->Listar_Detalle($idcotizacion);

    //$objetos = $objCotizacion->Listar_Objetos($idcotizacion);

    $param_moneda = $objCotizacion->Ver_Moneda_Reporte();
    foreach ($param_moneda as $row => $column) {
        $moneda = $column['CurrencyName'];
    }

    $info = $objCotizacion->Listar_Info($idcotizacion);

    if (is_array($info) || is_object($info)){
      foreach ($info as $row => $column) {
        $numero_cotizacion = $column["numero_cotizacion"];
        $fecha_cotizacion = $column["fecha_cotizacion"];
		
		if (!empty($fecha_cotizacion)) {
			$fecha_objeto = DateTime::createFromFormat('Y-m-d H:i:s', $fecha_cotizacion);
			if ($fecha_objeto !== false) {
				$fecha_cotizacion = $fecha_objeto->format('d/m/Y H:i:s');
			} else {
				echo "Error: El formato de fecha no es válido para '$fecha_cotizacion'.";
			}
		} else {
			echo "Error: La fecha está vacía o no se proporcionó.";
		}


		
       // $fecha_cotizacion = DateTime::createFromFormat('d-m-Y H:i:s', $fecha_cotizacion)->format('d/m/Y H:i:s');
        $tipo_pago = $column["tipo_pago"];
        $a_nombre = $column["a_nombre"];
        $entrega = $column["entrega"];
        $sumas = $column["sumas"];
        $iva = $column["iva"];
        $subtotal = $column["sumas"];
        $total_exento = $column["total_exento"];
        $retenido = $column["retenido"];
        $total_descuento = $column["total_descuento"];
        $total = $column["total"];
        $empleado = $column["empleado"];
        $direccion_cliente = $column["direccion_cliente"];
        $nit = $column['numero_nit'];
        $nit_cliente = $nit ;
        $telefono = $column['numero_telefono'];
        $email = $column['email'];
        $p_nombre_cliente = $column["nombre_cliente"];
        $fecha_cotizacion = $column["fecha_cotizacion"];
        $numero_cotizacion = $column["numero_cotizacion"];
        $cantidad = $column["cantidad"];
        $precio_unitario = $column["precio_unitario"];
        $importe = $column["importe"];
        $nombre_producto = $column["nombre_producto"];
        $exento = $column["exento"];
        $descuento = $column["descuento"];

      }
    }

 
    $objParametro =  new Parametro();
    $filas = $objParametro->Listar_Parametros();

    if (is_array($filas) || is_object($filas))
    {
        foreach ($filas as $row => $column)
        {
          $empresa = $column['nombre_empresa'];
          $propietario = $column['propietario'];
          $numero_nrc = $column['numero_nrc'];
          $direccion_empresa = $column['direccion_empresa'];
          $nit = $column['numero_nit'];
          

        }
    }

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
        $pdf->Cell(40, 10, 'Cotizacion', 0, 1, 'C');

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
        $pdf->Cell(100, 10, 'Cotizar a:', 0, 1); // Añade el texto "Facturar a"
        $pdf->SetFont('Arial', '', 8.5);
        $pdf->SetXY(10, 70);
        $pdf->MultiCell(100, 10, $p_nombre_cliente, 0); // Añade el nombre del cliente
        $pdf->SetXY(120, 40);
        $pdf->Cell(40, 5, 'Fecha', 0, 0, 'C'); // Añade el texto "Fecha"
        $pdf->SetXY(160, 40);
        $pdf->Cell(40, 5, 'Cotizacion #', 0, 1, 'C'); // Añade el texto "Factura #"
        $pdf->SetFont('Arial', '', 8.5);
        $pdf->SetXY(120, 45);
        $pdf->Cell(40, 10, $fecha_cotizacion, 0, 0, 'C'); // Añade la fecha
        $pdf->SetXY(160, 45);
        $pdf->Cell(40, 10, $numero_cotizacion, 0, 1, 'C'); // Añade el número de cotizacion
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
      //foreach ($objetos as $row) {
		  foreach ($listado as $row) {
    $pdf->Cell(30, 6, round($row['cantidad']), 1, 0, 'L', true);
    $pdf->Cell(80, 6, $row['nombre_producto'], 1, 0, 'L', true);
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
    $pdf->Text(170, $get_Y + 95, 'B/.'.$total_exento);
    $pdf->Text(130, $get_Y + 100, 'ITMBS(7%)');
    $pdf->Text(170, $get_Y + 100, 'B/.'.$iva);
    $pdf->Text(130, $get_Y + 105, 'DESCUENTO');
    $pdf->Text(170, $get_Y + 105, 'B/.'.'- '.$total_descuento);
    $pdf->SetFont('Arial', 'B', 8.5);
    $pdf->Text(130, $get_Y + 110, 'TOTAL A PAGAR');
    $pdf->SetFont('Arial', 'B', 8.5);
    $pdf->Text(170, $get_Y + 110, 'B/.'.$total);

    $pdf->Output();

    //}

  } catch (Exception $e) {

    $pdf->Text(22.8, 5, 'ERROR AL IMPRIMIR COTIZACION');
    $pdf->Output('I','COTIZACION_ERROR.pdf',true);

  }

 ?>
