<?php
session_start();
// Incluir el archivo de conexión
include 'C:\xampp\htdocs\silverngrok\gesnet_proyect\model\Conexion.php';

require 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\vendor\autoload.php';

// Incluir las clases necesarias de PhpSpreadsheet
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\IOFactory.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Shared\File.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\IReader.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\IReadFilter.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\DefaultReadFilter.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\BaseReader.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\Security\XmlScanner.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\Xlsx\BaseParserClass.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\Xlsx\Theme.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\Xlsx\Styles.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\Xlsx\Properties.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\Xlsx\SheetViews.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\Xlsx\SheetViewOptions.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\Xlsx\ColumnAndRowAttributes.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\Xlsx\PageSetup.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\Xlsx\Hyperlinks.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\Xlsx\WorkbookView.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Reader\Xlsx.php';
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
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Style\NumberFormat\BaseFormatter.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Style\NumberFormat\Formatter.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Style\NumberFormat.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Style\Protection.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Cell\Coordinate.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Calculation\Functions.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Cell\AddressRange.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Worksheet\Validations.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Cell\Cell.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Cell\DataType.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Cell\IgnoredErrors.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Cell\IValueBinder.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Cell\DefaultValueBinder.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\WriterPart.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\Writer\Xlsx\Chart.php';
require_once 'C:\xampp\htdocs\silverngrok\gesnet_proyect\lib\PhpSpreadsheet\IOFactory.php';
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

use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Reader\Xlsx\SheetViewOptions;

$conexion = Conexion::Conectar();

if (isset($_FILES['archivo_excel']['tmp_name'])) {
    $archivo_temporal = $_FILES['archivo_excel']['tmp_name'];

    // Leer el archivo Excel
    try {
        $spreadsheet = IOFactory::load($archivo_temporal);
    } catch (\PhpOffice\PhpSpreadsheet\Reader\Exception $e) {
        die('Error loading file: ' . $e->getMessage());
    }

    // Seleccionar la primera hoja
    $hoja = $spreadsheet->getActiveSheet();

    // Obtener los datos de la hoja
    $datos = $hoja->toArray(null, true, true, true);

    // Asumiendo que la primera fila contiene encabezados
    foreach ($datos as $fila) {
        $idproducto = $fila['A'];
        $codigo_interno = $fila['B'];
        $codigo_barra = $fila['C'];
        $codigo_alternativo = $fila['D'];
        $nombre_producto = $fila['E'];
        $precio_compra = $fila['F'];
        $precio_venta = $fila['G'];
        $precio_venta1 = $fila['H'];
        $precio_venta2 = $fila['I'];
        $precio_venta3 = $fila['J'];
        $precio_venta_mayoreo = $fila['K'];
        $stock = $fila['L'];
        $stock_min = $fila['M'];
        $idcategoria = $fila['N'];
        $idmarca = $fila['O'];
        $idpresentacion = $fila['P'];
        $estado = $fila['Q'];
        $exento = $fila['R'];
        $inventariable = $fila['S'];
        $perecedero = $fila['T'];
        $imagen = $fila['U'];
        $usuario = $_SESSION['user_id'];

        $sql = "INSERT INTO producto (idproducto, codigo_interno, codigo_barra, codigo_alternativo, nombre_producto, precio_compra, precio_venta, precio_venta1, precio_venta2, precio_venta3, precio_venta_mayoreo, stock, stock_min, idcategoria, idmarca, idpresentacion, estado, exento, inventariable, perecedero, imagen, usuario) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        $stmt = $conexion->prepare($sql);
        try {
            $stmt->execute([$idproducto, $codigo_interno, $codigo_barra, $codigo_alternativo, $nombre_producto, $precio_compra, $precio_venta, $precio_venta1, $precio_venta2, $precio_venta3, $precio_venta_mayoreo, $stock, $stock_min, $idcategoria, $idmarca, $idpresentacion, $estado, $exento, $inventariable, $perecedero, $imagen, $usuario]);
        } catch (PDOException $e) {


            $response['message'] = 'Error en la importacion';
            echo json_encode($response,$idproducto, $codigo_interno, $codigo_barra, $codigo_alternativo, $nombre_producto, $precio_compra, $precio_venta, $precio_venta1, $precio_venta2, $precio_venta3, $precio_venta_mayoreo, $stock, $stock_min, $idcategoria, $idmarca, $idpresentacion, $estado, $exento, $inventariable, $perecedero, $imagen, $usuario);
            exit;
        }
    }

    $response['success'] = true;
    $response['message'] = 'Archivo importado exitosamente';
} else {
    $response['message'] = 'No se ha proporcionado un archivo';
}

echo json_encode($response);

// Cerrar la conexión a la base de datos
$conexion = null;
?>