<?php
// Incluir el archivo de conexión
include 'C:\xampp\htdocs\silverngrok\gesnet_proyect\model\Conexion.php';

require 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\vendor\autoload.php';

// Incluir las clases necesarias de PhpSpreadsheet
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\IWriter.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\BaseWriter.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\IOFactory.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Spreadsheet.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Calculation\Calculation.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Calculation\Category.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Calculation\Engine\CyclicReferenceStack.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Calculation\Engine\Logger.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Calculation\Engine\BranchPruner.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\ReferenceHelper.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Theme.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\IComparable.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Worksheet\Worksheet.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Shared\StringHelper.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Collection\CellsFactory.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Collection\Cells.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Settings.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\simple-cache-master\src\CacheInterface.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Collection\Memory\SimpleCache3.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Worksheet\PageSetup.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Worksheet\PageMargins.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Worksheet\HeaderFooter.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Worksheet\SheetView.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Worksheet\Protection.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Worksheet\Dimension.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Worksheet\RowDimension.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Worksheet\ColumnDimension.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Worksheet\AutoFilter.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\BaseWriter.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Worksheet\AutoFilter\Column\Rule.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Shared\IntOrFloat.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Document\Properties.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Document\Security.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Style\Supervisor.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Style\Style.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Style\Font.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Style\Color.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Style\Fill.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Style\Borders.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Style\Border.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Style\Alignment.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Style\NumberFormat.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Style\Protection.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Cell\Coordinate.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Calculation\Functions.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Worksheet\Validations.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Cell\Cell.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Cell\DataType.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Cell\IgnoredErrors.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Cell\IValueBinder.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Cell\DefaultValueBinder.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\WriterPart.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\Chart.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\Chart.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Chart\DataSeries.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\Comments.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\ContentTypes.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\DocProps.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\Drawing.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\Rels.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\RelsRibbon.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\RelsVBA.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\StringTable.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\Style.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\Theme.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\Table.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\Workbook.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\Worksheet.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\HashTable.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Worksheet\Iterator.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Shared\XMLWriter.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\Xlsx\Namespaces.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Shared\Date.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\DefinedNames.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\AutoFilter.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\ZipStream3.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\ZipStream0.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\ZipStream2.php';


$conexion = Conexion::Conectar();

// Nombre del archivo Excel
$archivo_excel = 'exportacion_inventario.xlsx';

// Consulta para obtener los datos de la tabla
$sql = "SELECT * FROM view_productos";
$resultado = $conexion->query($sql);

if ($resultado->rowCount() > 0) {
    // Crear un nuevo objeto Spreadsheet
    $spreadsheet = new PhpOffice\PhpSpreadsheet\Spreadsheet();

    // Seleccionar la hoja activa
    $hoja = $spreadsheet->getActiveSheet();

    // Obtener los encabezados de las columnas
    $columnas = array();
    foreach ($resultado->fetch(PDO::FETCH_ASSOC) as $columna => $valor) {
        $columnas[] = $columna;
    }

    // Escribir los encabezados de las columnas en la primera fila de la hoja
    $hoja->fromArray($columnas, NULL, 'A1');

    // Rebobinar el cursor del resultado
    $resultado->execute();

    // Obtener los datos de la tabla y escribirlos en la hoja
    $fila_actual = 2; // Empezamos desde la fila 2 para dejar espacio para los encabezados
    while ($fila = $resultado->fetch(PDO::FETCH_ASSOC)) {
        $hoja->fromArray($fila, NULL, 'A' . $fila_actual);
        $fila_actual++;
    }

    // Crear un objeto Writer para guardar el archivo Excel
    $writer = new PhpOffice\PhpSpreadsheet\Writer\Xlsx($spreadsheet);

    // Guardar el archivo Excel en el directorio de descargas
    $writer->save($archivo_excel);

    // Cabeceras para descargar el archivo
    header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    header('Content-Disposition: attachment; filename="' . $archivo_excel . '"');
    header('Cache-Control: max-age=0');

    // Leer el archivo Excel y enviarlo al navegador
    readfile($archivo_excel);

    // Eliminar el archivo Excel después de descargarlo
    unlink($archivo_excel);
} else {
    echo "No se encontraron datos en la tabla.";
}

// Cerrar la conexión a la base de datos
$conexion = null;
?>
