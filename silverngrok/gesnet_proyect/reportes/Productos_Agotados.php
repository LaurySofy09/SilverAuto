<?php
require('fpdf/fpdf.php');

class PDF extends FPDF
{
    // Page header
    function Header()
    {
        if ($this->page == 1)
        {
            $this->SetFont('Arial','B',15);
            $this->Cell(105);
            $this->Cell(170,10,'REPORTE DE PRODUCTOS AGOTADOS',0,0,'C');
            $this->Ln(20);
        }
    }

    // Page footer
    function Footer()
    {
        $this->SetY(-15);
        $this->SetFont('Arial','I',10); // Tamaño de fuente más grande
        $this->Cell(275,10,'Pagina '.$this->PageNo().'/{nb}',0,0,'L');
        $this->Cell(0,10,date('d/m/Y H:i:s'),0,0,'R'); // Alineado a la derecha
    }
}

spl_autoload_register(function($className){
    $model = "../model/". $className ."_model.php";
    $controller = "../controller/". $className ."_controller.php";
    require_once($model);
    require_once($controller);
});

$objProducto = new Producto();
$listado = $objProducto->Listar_Productos_Agotados();

try {
    $pdf = new PDF('L','mm','A3'); // Tamaño de la página A3
    $pdf->AliasNbPages();
    $pdf->AddPage();
    $pdf->SetFont('Arial','',10); // Tamaño de la fuente más pequeño
    $pdf->SetFillColor(255,255,255);

    // Ajuste del ancho de las columnas y espacio entre ellas
    $pdf->Cell(25,5,'Cod. Interno',0,0,'L',1);
    $pdf->Cell(25,5,'Cod. Barra',0,0,'L',1);
    $pdf->Cell(30,5,'Cod. Alternativo',0,0,'L',1);
    $pdf->Cell(115,5,'Producto',0,0,'L',1); // Ajustar ancho
    $pdf->Cell(50,5,'Marca',0,0,'L',1); // Ajustar ancho
    $pdf->Cell(30,5,'Presentacion',0,0,'L',1);
    $pdf->Cell(20,5,'Costo',0,0,'C',1); // Reducir ancho
    $pdf->Cell(20,5,'P. Venta1',0,0,'C',1); // Reducir ancho
    $pdf->Cell(20,5,'P. Venta2',0,0,'C',1); // Reducir ancho
    $pdf->Cell(20,5,'P. Venta3',0,0,'C',1); // Reducir ancho
    $pdf->Cell(20,5,'P. Venta4',0,0,'C',1); // Reducir ancho
    $pdf->Cell(20,5,'Stock',0,0,'C',1); // Reducir ancho

    $pdf->Line(9,28,400,28); // Línea superior
    $pdf->Line(9,37,400,37); // Línea inferior
    $pdf->Ln(9);
    $total = 0;

    if (is_array($listado) || is_object($listado))
    {
        foreach ($listado as $row => $column) {
            $pdf->setX(9);
            $pdf->Cell(25,5,$column["codigo_interno"],0,0,'L',1);
            $pdf->Cell(25,5,$column["codigo_barra"],0,0,'L',1);
            $pdf->Cell(30,5,$column["codigo_alternativo"],0,0,'L',1);
            $pdf->Cell(115,5,$column["nombre_producto"],0,0,'L',1); // Ajustar ancho
            $pdf->Cell(50,5,$column["nombre_marca"],0,0,'L',1); // Ajustar ancho
            $pdf->Cell(30,5,$column["siglas"],0,0,'L',1);
            $pdf->Cell(20,5,$column["precio_compra"],0,0,'C',1); // Reducir ancho
            $pdf->Cell(20,5,$column["precio_venta"],0,0,'C',1); // Reducir ancho
            $pdf->Cell(20,5,$column["precio_venta1"],0,0,'C',1); // Reducir ancho
            $pdf->Cell(20,5,$column["precio_venta2"],0,0,'C',1); // Reducir ancho
            $pdf->Cell(20,5,$column["precio_venta3"],0,0,'C',1); // Reducir ancho
            $pdf->Cell(20,5,$column["stock"],0,0,'C',1); // Reducir ancho
            $pdf->Ln(6);
            $get_Y = $pdf->GetY();
            $total = $total + 1 ;
        }

        $pdf->Line(9,$get_Y+1,400,$get_Y+1); // Línea final
        $pdf->SetFont('Arial','B',11);
        $pdf->Text(10,$get_Y + 10,'TOTAL DE PRODUCTOS AGOTADOS : '.number_format($total, 2, '.', ','));
    }

    $pdf->Output('I','Productos_Agotados.pdf');

} catch (Exception $e) {
    $pdf = new PDF();
    $pdf->AliasNbPages();
    $pdf->AddPage('L','Letter');
    $pdf->Text(50,50,'ERROR AL IMPRIMIR');
    $pdf->SetFont('Times','',12);
    $pdf->Output();
}
?>
