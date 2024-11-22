<?php
require('fpdf/fpdf.php');

class PDF_Invoice extends FPDF {
    // Header
    function Header() {
        // Logo
        $this->Image(__DIR__ . '/../web/assets/images/logo_taller.png', 10, 10, 50); // Ajustar las coordenadas y dimensiones según sea necesario
        
        // Invoice text
        $this->SetFont('Arial', 'B', 18); // Tamaño de la fuente más pequeño
        $this->SetXY(140, 30); // Ajustar la posición más a la izquierda
        $this->Cell(40, 10, 'Invoice', 0, 1, 'C');
    }

    // Footer
    function Footer() {
        // Posición a 1.5 cm del final
        $this->SetY(-15);
        $this->SetFont('Arial', 'I', 8);
        $this->Cell(0, 10, 'Pagina ' . $this->PageNo() . '/{nb}', 0, 0, 'C');
    }

    // Tabla de la factura
    function InvoiceTable($header, $data) {
    // Posición inicial de la tabla
    $this->SetY(110); // Ajustar la posición Y según sea necesario para alinear con la línea inferior de los cuadros "Rep" y "JO"
    
    // Cabecera
    $this->SetFont('Arial', 'B', 12);
    $this->Cell(30, 7, $header[0], 1);
    $this->Cell(80, 7, $header[1], 1);
    $this->Cell(40, 7, $header[2], 1);
    $this->Cell(40, 7, $header[3], 1);
    $this->Ln();

    // Datos
    $this->SetFont('Arial', '', 12);
     foreach ($data as $row) {
        $this->Cell(40, 6, $row['cantidad'], 1);
        $this->Cell(40, 6, $row['descripcion'], 1);
        $this->Cell(40, 6, $row['precio_unitario'], 1);
        $this->Cell(40, 6, $row['importe'], 1);
        $this->Ln();
    }
}

function AddInvoiceDetails($fecha_venta, $numero_comprobante, $p_nombre_cliente) {
    $this->SetFont('Arial', '', 12);
    
    // Cuadro alrededor de "Facturar a"
    $this->Rect(10, 60, 100, 10); // Cuadro con coordenadas (x, y) y dimensiones (w, h) para "Facturar a"
    $this->SetXY(10, 60);
    $this->Cell(100, 10, 'Facturar a:', 0, 1); // Texto "Facturar a" sin borde

    // Cuadro alrededor del nombre del cliente
    $this->Rect(10, 70, 100, 30); // Cuadro con coordenadas (x, y) y dimensiones (w, h) para el nombre del cliente
    $this->SetXY(10, 70);
    $this->MultiCell(100, 10, $p_nombre_cliente, 0); // Nombre del cliente sin borde

    // Cuadros para "Rep" y "JO" alineados y pegados a la derecha
    $this->Rect(160, 100, 20, 10); // Cuadro para "Rep"
    $this->Rect(180, 100, 20, 10); // Cuadro para "JO"
    $this->SetXY(160, 100);
    $this->Cell(20, 10, 'Rep', 0, 0, 'C'); // Texto "Rep" centrado sin borde
    $this->SetXY(180, 100);
    $this->Cell(20, 10, 'JO', 0, 0, 'C'); // Texto "JO" centrado sin borde

    // Cuadro alrededor de "Fecha" y "Factura #"
    $this->Rect(120, 40, 40, 10); // Cuadro para "Fecha"
    $this->Rect(160, 40, 40, 10); // Cuadro para "Factura #"
    $this->Rect(120, 50, 40, 10); // Cuadro para el valor de la fecha
    $this->Rect(160, 50, 40, 10); // Cuadro para el valor del número de factura

    // Etiquetas "Fecha" y "Factura #"
    $this->SetXY(120, 40); // Ajustar la posición para la primera fila de etiquetas
    $this->Cell(40, 10, 'Fecha', 0, 0, 'C'); // Etiqueta Fecha sin borde, centrada
    $this->Cell(40, 10, 'Factura #', 0, 1, 'C'); // Etiqueta Factura # sin borde, centrada y salto de línea

    // Valores de "Fecha" y "Factura #"
    $this->SetXY(120, 50); // Ajustar la posición para la segunda fila de valores
    $this->Cell(40, 10, .$fecha_venta, 0, 0, 'C'); // Valor de la Fecha sin borde, centrado
    $this->Cell(40, 10, .$numero_comprobante, 0, 1, 'C'); // Valor del Número de Factura sin borde, centrado y salto de línea
}

    function AddFooterLegend() {
        $this->SetFont('Arial', '', 8);
        $this->SetXY(10, 220); // Ajustar la posición según sea necesario
        $this->MultiCell(0, 4, "NO SE ACEPTAN CAMBIOS NI DEVOLUCIONES EN PIEZAS ELECTRICAS.\nNO SE ACEPTAN CAMBIOS NI DEVOLUCIONES EN PEDIDOS ESPECIALES.\nNO SE ACEPTAN CAMBIOS NI DEVOLUCIONES DESPUES DE 15 DIAS.\nPARA GARANTIAS, CAMBIOS Y DEVOLUCIONES, DEBE PRESENTAR \nFACTURA ORIGINAL FIRMADA Y EN BUEN ESTADO.\nTODO CAMBIO DE PIEZA DEBE REALIZARSE ANTES DE 24 HORAS.\nNO SE RECIBEN PIEZAS CON EMPAQUE DAÑADO O SUCIO.\nREPUESTOS BIEN VENDIDOS NO TIENEN DEVOLUCION.\nPIEZAS MAL INSTALADAS NO TIENEN GARANTIA.");
    }

    function AddTotals($subtotal, $exento, $descuento, $total) {
    $this->SetFont('Arial', '', 12);

    // Textos a la izquierda
    $this->SetXY(140, 220); // Ajustar las coordenadas según sea necesario para subir un poco
    $this->Cell(30, 10, 'Subtotal:', 0, 0, 'R');
    $this->SetXY(140, 230); // Ajustar las coordenadas según sea necesario
    $this->Cell(30, 10, 'ITBMS (7.0%):', 0, 0, 'R');
    $this->SetXY(140, 240); // Ajustar las coordenadas según sea necesario
    $this->Cell(30, 10, 'Descuento:', 0, 0, 'R');
    $this->SetXY(140, 250); // Ajustar las coordenadas según sea necesario
    $this->Cell(30, 10, 'Total:', 0, 0, 'R');

    // Montos a la derecha más pegados entre sí
    $this->SetXY(150, 220); // Ajustar las coordenadas según sea necesario
    $this->Cell(40, 10, $subtotal, 0, 0, 'R');
    $this->SetXY(150, 230); // Ajustar las coordenadas según sea necesario
    $this->Cell(40, 10, $exento, 0, 0, 'R');
    $this->SetXY(150, 240); // Ajustar las coordenadas según sea necesario
    $this->Cell(40, 10, $descuento, 0, 0, 'R');
    $this->SetXY(150, 250); // Ajustar las coordenadas según sea necesario
    $this->Cell(40, 10, $total, 0, 0, 'R');
}


}

$pdf = new PDF_Invoice();
$pdf->AliasNbPages();
$pdf->AddPage();

// Datos de ejemplo para la tabla de la factura
$header = array('Cantidad', 'Descripcion', 'Precio x unidad', 'Total');
$detalle = $pdo->query("SELECT cantidad, descripcion, precio_unitario, importe FROM detalle_factura");
$data = $detalle->fetchAll(PDO::FETCH_ASSOC);

// Añadir detalles de la factura
$pdf->AddInvoiceDetails($fecha_venta, $numero_comprobante, $p_nombre_cliente);

// Añadir tabla de la factura
$pdf->InvoiceTable($header, $data);

// Añadir subtotales y totales
$pdf->AddTotals($subtotal, $exento, $descuento, $total);

// Añadir leyenda en el pie de página
$pdf->AddFooterLegend();

$pdf->Output();
?>
<?php
