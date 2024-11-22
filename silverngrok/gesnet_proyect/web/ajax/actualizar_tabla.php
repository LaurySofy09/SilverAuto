<?php
session_start();
$tipo_usuario = $_SESSION['user_tipo'];

spl_autoload_register(function($className) {
    $model = "../../model/" . $className . "_model.php";
    $controller = "../../controller/" . $className . "_controller.php";

    require_once($model);
    require_once($controller);
});

$objProducto = new Producto();
// Obtener los resultados como un array asociativo
$html = '<table class="table datatable-basic table-borderless table-hover table-xxs">';


$html .= '<thead><tr><th>Codigo Interno-Barra-Alternativo</th>
                        <th>Producto</th>
                        <th>Marca</th>
                        <th>Presentacion</th>
                        <th>S.Min.</th>
                        <th>Stock</th>
                        <th>P.Compra</th>
                        <th>P.Venta1</th>
                        <th>P.Venta2</th>
                        <th>P.Venta3</th>
                        <th>P.Venta4</th>
                        <th class="text-center">Opciones</th></tr></thead>';

$html .='<tbody>';

$filas = $objProducto->Listar_Productos();
if (is_array($filas) || is_object($filas)) {

    foreach ($filas as $row => $column) {
        $stock_print = "";
        $codigo_print = "";
        $codigo_barra = $column['codigo_barra'];
        $inventariable = $column['inventariable'];
        $stock = $column['stock'];
        $stock_min = $column['stock_min'];
        $codigo_alternativo = $column['codigo_alternativo'];
            $codigo_interno = $column['codigo_interno'];

            if (($codigo_barra == '') && ($codigo_alternativo == '')) {
                $codigo_print = $codigo_interno;
            } else if (($codigo_barra != '') && ($codigo_alternativo == '')) {
                $codigo_print = $codigo_interno.'-'.$codigo_barra;
            } else if (($codigo_barra == '') && ($codigo_alternativo != '')) {
                $codigo_print = $codigo_interno.'-'.$codigo_alternativo;
            } else if (($codigo_barra != '') && ($codigo_alternativo != '')) {
                $codigo_print = $codigo_interno.'-'.$codigo_barra.'-'.$codigo_alternativo;
            }
            else {
                $codigo_print = $codigo_interno;
            }

        if ($inventariable == 1) {
            if ($stock >= 1 && $stock < $stock_min) {
                $stock_print = '<span class="label label-warning label-rounded"><span
                    class="text-bold">POR AGOTARSE</span></span>';
            } else if ($stock == $stock_min) {

                $stock_print = '<span class="label label-info label-rounded"><span
                    class="text-bold">EN MINIMO</span></span>';
            } else if ($stock > $stock_min) {

                $stock_print = '<span
                    class="">' . $stock . '</span>';
            } else if ($stock == 0) {

                $stock_print = '<span class="label label-danger label-rounded">
                    <span class="text-bold">AGOTADO</span></span>';
            }
        } else {

            $stock_print = '<span class="label label-primary label-rounded"><span
                    class="text-bold">SERVICIO</span></span>';
        }

        $html .='<tr>';
        $html .='<td>'. $codigo_print.'</td>';
        $html .='<td>'. $column['nombre_producto'].'</td>';
        $html .='<td>'. $column['nombre_marca'].'</td>';
        $html .='<td>'. $column['nombre_presentacion'].'</td>';
        $html .='<td>'. $column['stock_min'].'</td>';
        $html .='<td>'. $stock_print.'</td>';
        $html .='<td>'. $column['precio_compra'].'</td>';
        $html .='<td>'. $column['precio_venta'].'</td>';
        $html .='<td>'. $column['precio_venta1'].'</td>';
        $html .='<td>'. $column['precio_venta2'].'</td>';
        $html .='<td>'. $column['precio_venta3'].'</td>';
        $html .='<td class="text-center">';
        $html .='<ul class="icons-list">';
        $html .='<li class="dropdown">';
        $html .='<a href="#" class="dropdown-toggle" data-toggle="dropdown"><i class="icon-menu9"></i></a>';
        $html .='<ul class="dropdown-menu dropdown-menu-right">';
        $html .='<li><a onclick="openProducto(\'editar\','.$column["idproducto"].','.$column["codigo_interno"]. ','.$column["codigo_interno"]. ','.$column["codigo_barra"]. ','.$column["codigo_alternativo"]. ','.$column["nombre_producto"]. ','.$column["precio_compra"] . ','.$column["precio_venta"]. ','.$column["precio_venta_mayoreo"] . ','.$column["stock"] .','.$column["stock_min"]  .','.$column["idcategoria"] .','.$column["idmarca"] .','.$column["idpresentacion"] .','.$column["estado"] .','.$column["exento"] .','.$column["inventariable"] .','.$column["perecedero"] .','.$column["imagen"] .')">  <i class="icon-pencil6"></i> Editar</a></li>';

        $html .='<li><a href="javascript:;" data-toggle="modal" data-target="#modal_iconified_barcode" ';
        $html .='onclick="openBarcode(\''.$column["codigo_barra"]. '\','.$column["codigo_alternativo"] . '\','.$column["codigo_interno"] . ','.$column["nombre_producto"] . ','.$column["idproducto"] . ')">';
        $html .='<i class="icon-barcode2"></i>Codigo de Barra</a></li>';
        $html .='<li>  <a href="javascript:;" data-toggle="modal" data-target="#modal_iconified" onclick="openProducto(\'ver\','.$column["idproducto"].','. $column["codigo_interno"]. ','. $column["codigo_barra"]. ','. $column["codigo_alternativo"]. ','. $column["nombre_producto"]. ','. $column["precio_compra"]. ','. $column["precio_venta"]. ','. $column["precio_venta_mayoreo"]. ','. $column["stock"]. ','. $column["stock_min"]. ','. $column["idcategoria"]. ','. $column["idmarca"]. ','. $column["idpresentacion"]. ','. $column["estado"]. ','. $column["exento"]. ','. $column["inventariable"]. ','. $column["perecedero"]. ','. $column["imagen"]. ')">';
        $html .= '<i class=" icon-eye8"> </i> Ver</a></li>  </ul>  </li>  </ul> </td>  </tr>';

    }

}


$html .='</tbody>';
$html .='</table>';

echo $html;
?>
