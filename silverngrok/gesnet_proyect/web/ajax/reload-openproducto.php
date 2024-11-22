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
?>


<!-- Basic initialization -->
<div class="panel panel-flat">
    <div class="breadcrumb-line">
        <ul class="breadcrumb">
            <li><a href="?View=Inicio"><i class="icon-home2 position-left"></i> Inicio</a></li>
            <li><a href="javascript:;">Inventario</a></li>
            <li class="active">Consultar Inventario</li>
        </ul>
    </div>
    <div class="panel-heading">
        <h5 class="panel-title">Consultar Inventario</h5>

        <div class="heading-elements">
            <?php if ($tipo_usuario == '1') { ?>
                <button type="button" class="btn btn-primary heading-btn"
                        onclick="newProducto()">
                    <i class="icon-database-add"></i> Agregar Nuevo/a</button>

                <div class="btn-group">
                    <button type="button" class="btn btn-info dropdown-toggle" data-toggle="dropdown">
                        <i class="icon-printer2 position-left"></i> Imprimir Reporte
                        <span class="caret"></span></button>
                    <ul class="dropdown-menu dropdown-menu-right">
                        <li><a id="print_activos" href="javascript:void(0)"
                               ><i class="icon-file-pdf"></i> Productos Activos</a></li>
                        <li class="divider"></li>
                        <li><a id="print_inactivos" href="javascript:void(0)">
                                <i class="icon-file-pdf"></i> Productos Inactivos</a></li>
                        <li class="divider"></li>
                        <li><a id="print_agotados" href="javascript:void(0)">
                                <i class="icon-file-pdf"></i> Productos Agotados</a></li>
                        <li class="divider"></li>
                        <li><a id="print_vigentes" href="javascript:void(0)">
                                <i class="icon-file-pdf"></i> Productos Vigentes</a></li>
                    </ul>
                </div>

                <div class="btn-group">
                    <button type="button" class="btn btn-group dropdown-toggle" data-toggle="dropdown">
                        <i class="glyphicon glyphicon-transfer"></i> Importar/Exportar Inventario
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-right">
                        <li><a onclick="seleccionarArchivo('csv')"><i class="glyphicon glyphicon-save-file"></i> Importar CSV</a></li>
                        <li><a onclick="document.getElementById('archivo_excel').click();"><i class="glyphicon glyphicon-save-file"></i> Importar Excel</a></li>
                        <li class="divider"></li>
                        <li><a onclick="accion('exportar_csv')"><i class="glyphicon glyphicon-open-file"></i> Exportar CSV</a></li>
                        <li><a onclick="accion('exportar_excel')"><i class="glyphicon glyphicon-open-file"></i> Exportar Excel</a></li>
                    </ul>
                    </div>

                     <button type="button" class="btn btn-warning heading-btn"
                        onclick="Historial()">
                    <i class="glyphicon glyphicon-time"></i> Historial</button>

            <?php } ?>

        </div>
    </div>
    <div class="panel-body">
    </div>
    <div id="reload-div">
        <table class="table datatable-basic table-borderless table-hover table-xxs">
            <?php if ($tipo_usuario == '1') { ?>
                <thead>
                    <tr>
                        <th style="white-space: nowrap;">Codigo Interno-Barra-Alternativo</th>
                        <th>Producto</th>
                        <th>Marca</th>
                        <th>Presentacion</th>
                        <th>S.Min.</th>
                        <th>Stock</th>
                        <th>P.Compra</th>
                        <th style="white-space: nowrap;">P.Venta 1</th>
                        <th style="white-space: nowrap;">P.Venta 2</th>
                        <th style="white-space: nowrap;">P.Venta 3</th>
                        <th style="white-space: nowrap;">P.Venta 4</th>
                        <th class="text-center">Opciones</th>
                    </tr>
                </thead>



                <tbody>

                    <?php
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
                            ?>
                            <tr>
                                <td><?php print($codigo_print); ?></td>
                                <td><?php print($column['nombre_producto']); ?></td>
                                <td><?php print($column['nombre_marca']); ?></td>
                                <td><?php print($column['nombre_presentacion']); ?></td>
                                <td><?php print($column['stock_min']); ?></td>
                                <td><?php print($stock_print); ?></td>
                                <td><?php print($column['precio_compra']); ?></td>
                                <td><?php print($column['precio_venta']); ?></td>
                                <td><?php print($column['precio_venta1']); ?></td>
                                <td><?php print($column['precio_venta2']); ?></td>
                                <td><?php print($column['precio_venta3']); ?></td>
                                <td class="text-center">
                                    <ul class="icons-list">
                                        <li class="dropdown">
                                            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                                                <i class="icon-menu9"></i>
                                            </a>

                                            <ul class="dropdown-menu dropdown-menu-right">
                                                <li><a
                                                        href="javascript:;" data-toggle="modal" data-target="#modal_iconified"
                                                        onclick="openProducto('editar',
                                                                                                                            '<?php print($column["idproducto"]); ?>',
                                                                                                                            '<?php print($column["codigo_interno"]); ?>',
                                                                                                                            '<?php print($column["codigo_barra"]); ?>',
                                                                                                                             '<?php print($column["codigo_alternativo"]); ?>',
                                                                                                                            '<?php print($column["nombre_producto"]); ?>',
                                                                                                                            '<?php print($column["precio_compra"]); ?>',
                                                                                                                            '<?php print($column["precio_venta"]); ?>',
                                                                                                                            '<?php print($column["precio_venta1"]); ?>',
                                                                                                                            '<?php print($column["precio_venta2"]); ?>',
                                                                                                                            '<?php print($column["precio_venta3"]); ?>',
                                                                                                                            '<?php print($column["precio_venta_mayoreo"]); ?>',
                                                                                                                            '<?php print($column["stock"]); ?>',
                                                                                                                            '<?php print($column["stock_min"]); ?>',
                                                                                                                            '<?php print($column["idcategoria"]); ?>',
                                                                                                                            '<?php print($column["idmarca"]); ?>',
                                                                                                                            '<?php print($column["idpresentacion"]); ?>',
                                                                                                                            '<?php print($column["estado"]); ?>',
                                                                                                                            '<?php print($column["exento"]); ?>',
                                                                                                                            '<?php print($column["inventariable"]); ?>',
                                                                                                                            '<?php print($column["perecedero"]); ?>',
                                                                                                                            '<?php print($column["imagen"]); ?>')">
                                                        <i class="icon-pencil6">
                                                        </i> Editar</a></li>
                                                <li><a
                                                        href="javascript:;" data-toggle="modal" data-target="#modal_iconified_barcode"
                                                        onclick="openBarcode(
                                                                                                                            '<?php print($column["codigo_barra"]); ?>',
                                                                                                                            '<?php print($column["codigo_alternativo"]); ?>',
                                                                                                                            '<?php print($column["codigo_interno"]); ?>',
                                                                                                                            '<?php print($column["nombre_producto"]); ?>',
                                                                                                                            '<?php print($column["idproducto"]); ?>')">
                                                        <i class="icon-barcode2">
                                                        </i>Codigo de Barra</a></li>
                                                <li>
                                                    <a
                                                        href="javascript:;" data-toggle="modal" data-target="#modal_iconified"
                                                        onclick="openProducto('ver',
                                                                                                                            '<?php print($column["idproducto"]); ?>',
                                                                                                                            '<?php print($column["codigo_interno"]); ?>',
                                                                                                                            '<?php print($column["codigo_barra"]); ?>',
                                                                                                                            '<?php print($column["codigo_alternativo"]); ?>',
                                                                                                                            '<?php print($column["nombre_producto"]); ?>',
                                                                                                                            '<?php print($column["precio_compra"]); ?>',
                                                                                                                            '<?php print($column["precio_venta"]); ?>',
                                                                                                                            '<?php print($column["precio_venta1"]); ?>',
                                                                                                                            '<?php print($column["precio_venta2"]); ?>',
                                                                                                                            '<?php print($column["precio_venta3"]); ?>',
                                                                                                                            '<?php print($column["precio_venta_mayoreo"]); ?>',
                                                                                                                            '<?php print($column["stock"]); ?>',
                                                                                                                            '<?php print($column["stock_min"]); ?>',
                                                                                                                            '<?php print($column["idcategoria"]); ?>',
                                                                                                                            '<?php print($column["idmarca"]); ?>',
                                                                                                                            '<?php print($column["idpresentacion"]); ?>',
                                                                                                                            '<?php print($column["estado"]); ?>',
                                                                                                                            '<?php print($column["exento"]); ?>',
                                                                                                                            '<?php print($column["inventariable"]); ?>',
                                                                                                                            '<?php print($column["perecedero"]); ?>',
                                                                                                                            '<?php print($column["imagen"]); ?>')">
                                                        <i class=" icon-eye8">
                                                        </i> Ver</a></li>
                                            </ul>
                                        </li>
                                    </ul>
                                </td>
                            </tr>
                            <?php
                        }
                    }
                    ?>

                </tbody>

<?php } else { ?>
                <thead>
                    <tr>
                        <th style="white-space: nowrap;">Codigo Interno-Barra-Alternativo</th>
                        <th>Producto</th>
                        <th>Marca</th>
                        <th>Presentacion</th>
                        <th>S.Min.</th>
                        <th>Stock</th>
                        <th style="white-space: nowrap;">P.Venta 1</th>
                        <th style="white-space: nowrap;">P.Venta 2</th>
                        <th style="white-space: nowrap;">P.Venta 3</th>
                        <th style="white-space: nowrap;">P.Venta 4</th>
                        <th class="text-center">Opciones</th>
                    </tr>
                </thead>


                <tbody>

    <?php
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
            ?>
                            <tr>
                                <td><?php print($codigo_print); ?></td>
                                <td><?php print($column['nombre_producto']); ?></td>
                                <td><?php print($column['nombre_marca']); ?></td>
                                <td><?php print($column['nombre_presentacion']); ?></td>
                                <td><?php print($column['stock_min']); ?></td>
                                <td class="success"><?php print($stock_print); ?></td>
                                <td><?php print($column['precio_venta']); ?></td>
                                <td class="text-center">
                                    <ul class="icons-list">
                                        <li class="dropdown">
                                            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                                                <i class="icon-menu9"></i>
                                            </a>

                                            <ul class="dropdown-menu dropdown-menu-right">
                                                <li><a
                                                        href="javascript:;" data-toggle="modal" data-target="#modal_iconified_barcode"
                                                        onclick="openBarcode(
                                                                                                                            '<?php print($column["codigo_barra"]); ?>',
                                                                                                                            '<?php print($column["codigo_alternativo"]); ?>',
                                                                                                                            '<?php print($column["codigo_interno"]); ?>',
                                                                                                                            '<?php print($column["nombre_producto"]); ?>',
                                                                                                                            '<?php print($column["idproducto"]); ?>')">
                                                        <i class="icon-barcode2">
                                                        </i>Codigo de Barra</a></li>
                                                <li><a
                                                        href="javascript:;" data-toggle="modal" data-target="#modal_iconified"
                                                        onclick="openProducto('ver',
                                                                                                                            '<?php print($column["idproducto"]); ?>',
                                                                                                                            '<?php print($column["codigo_interno"]); ?>',
                                                                                                                            '<?php print($column["codigo_barra"]); ?>',
                                                                                                                            '<?php print($column["codigo_alternativo"]); ?>',
                                                                                                                            '<?php print($column["nombre_producto"]); ?>',
                                                                                                                            '<?php print($column["precio_compra"]); ?>',
                                                                                                                            '<?php print($column["precio_venta"]); ?>',
                                                                                                                            '<?php print($column["precio_venta1"]); ?>',
                                                                                                                            '<?php print($column["precio_venta2"]); ?>',
                                                                                                                            '<?php print($column["precio_venta3"]); ?>',
                                                                                                                            '<?php print($column["precio_venta_mayoreo"]); ?>',
                                                                                                                            '<?php print($column["stock"]); ?>',
                                                                                                                            '<?php print($column["stock_min"]); ?>',
                                                                                                                            '<?php print($column["idcategoria"]); ?>',
                                                                                                                            '<?php print($column["idmarca"]); ?>',
                                                                                                                            '<?php print($column["idpresentacion"]); ?>',
                                                                                                                            '<?php print($column["estado"]); ?>',
                                                                                                                            '<?php print($column["exento"]); ?>',
                                                                                                                            '<?php print($column["inventariable"]); ?>',
                                                                                                                            '<?php print($column["perecedero"]); ?>',
                                                                                                                            '<?php print($column["imagen"]); ?>')">
                                                        <i class=" icon-eye8">
                                                        </i> Ver</a></li>
                                            </ul>
                                        </li>
                                    </ul>
                                </td>
                            </tr>
                                                        <?php
                                                    }
                                                }
                                                ?>

                </tbody>


                                            <?php } ?>
        </table>
    </div>
</div>

<!-- Iconified modal -->
<div id="modal_iconified" class="modal fade">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h5 class="modal-title"><i class="icon-pencil7"></i> &nbsp; <span class="title-form"></span></h5>
            </div>

            <form role="form" autocomplete="off" class="form-validate-jquery" id="frmModal" enctype="multipart/form-data">
                <div class="modal-body" id="modal-container">

                    <div class="alert alert-info alert-styled-left text-blue-800 content-group">
                        <span class="text-semibold">Estimado usuario</span>
                        Los campos remarcados con <span class="text-danger"> * </span> son necesarios..
                        <button type="button" class="close" data-dismiss="alert">×</button>
                        <input type="hidden" id="txtID" name="txtID" class="form-control" value="">
                        <input type="hidden" id="txtProceso" name="txtProceso" class="form-control" value="">
                    </div>


                    <div class="form-group">
                        <div class="row">
                            <div class="col-sm-4">
                                <label>Codigo</label>
                                <input type="text" id="txtCodigo" name="txtCodigo" placeholder="AUTOGENERADO"
                                       class="form-control" style="text-transform:uppercase;"
                                       onkeyup="javascript:this.value = this.value.toUpperCase();" readonly disabled="disabled">
                            </div>

                            <div class="col-sm-4">
                                <label>Barra</label>
                                <div class="input-group">
                                    <span class="input-group-addon"><i class="icon-barcode2"></i></span>
                                    <input type="text" id="txtCodigoBarra" name="txtCodigoBarra" placeholder="0DA85808DS08"
                                           class="form-control" style="text-transform:uppercase;"
                                           onkeyup="javascript:this.value = this.value.toUpperCase();">
                                </div>
                            </div>

                            <div class="col-sm-4">
                                <label>Codigo alternativo</label>
                                <div class="input-group">
                                    <span class="input-group-addon"><i class="glyphicon glyphicon-tag"></i></span>
                                    <input type="text" id="txtCodigoAlt" name="txtCodigoAlt" placeholder="0DA85808DS08"
                                           class="form-control" style="text-transform:uppercase;"
                                           onkeyup="javascript:this.value = this.value.toUpperCase();">
                                </div>
                            </div>

                        </div>
                    </div>

                    <div class="form-group">
                        <div class="row">
                            <div class="col-sm-12">
                                <label>Producto <span class="text-danger">*</span></label>
                                <input type="text" id="txtProducto" name="txtProducto" placeholder="EJ. MOUSE RAZER"
                                       class="form-control" style="text-transform:uppercase;"
                                       onkeyup="javascript:this.value = this.value.toUpperCase();">
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="row">
                            <div class="col-sm-6">
                                <label>Stock <span class="text-danger">*</span></label>
                                <input type="text" id="txtStock" name="txtStock" placeholder="0"
                                       class="touchspin-prefix" value="0" style="text-transform:uppercase;"
                                       onkeyup="javascript:this.value = this.value.toUpperCase();">
                            </div>

<?php if ($tipo_usuario == '1'): ?>
                                <div class="col-sm-6">
                                    <label>Precio Compra <span class="text-danger">*</span></label>
                                    <input type="text" id="txtPCompra" name="txtPCompra" placeholder="EJ. 1.00"
                                           class="touchspin-prefix" value="0" style="text-transform:uppercase;"
                                           onkeyup="javascript:this.value = this.value.toUpperCase();">
                                </div>
<?php endif; ?>


                        </div>
                    </div>

                    <div class="form-group">
                        <div class="row">
                            <div class="col-sm-6">
                                <label>Precio Venta 1 <span class="text-danger">*</span></label>
                                <input type="text" id="txtPVenta" name="txtPVenta" placeholder="EJ. 1.50"
                                       class="touchspin-prefix" value="0" style="text-transform:uppercase;"
                                       onkeyup="javascript:this.value = this.value.toUpperCase();">
                            </div>

                            <div class="col-sm-6">
                                <label>Precio Venta 2</label>
                                <input type="text" id="txtPVenta1" name="txtPVenta1" placeholder="EJ. 1.50"
                                       class="touchspin-prefix" value="0" style="text-transform:uppercase;"
                                       onkeyup="javascript:this.value = this.value.toUpperCase();">
                            </div>
                           
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="row">
                            <div class="col-sm-6">
                                <label>Precio Venta 3</label>
                                <input type="text" id="txtPVenta2" name="txtPVenta2" placeholder="EJ. 1.50"
                                       class="touchspin-prefix" value="0" style="text-transform:uppercase;"
                                       onkeyup="javascript:this.value = this.value.toUpperCase();">
                            </div>

                            <div class="col-sm-6">
                                <label>Precio Venta 4</label>
                                <input type="text" id="txtPVenta3" name="txtPVenta3" placeholder="EJ. 1.50"
                                       class="touchspin-prefix" value="0" style="text-transform:uppercase;"
                                       onkeyup="javascript:this.value = this.value.toUpperCase();">
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="row">
                            <div class="col-sm-6">
                                <label>Precio Venta Por Mayor <span class="text-danger">*</span></label>
                                <input type="text" id="txtPVentaM" name="txtPVentaM" placeholder="EJ. 1.25"
                                       class="touchspin-prefix" value="0" style="text-transform:uppercase;"
                                       onkeyup="javascript:this.value = this.value.toUpperCase();">
                            </div>

                            <div class="col-sm-6">
                                <label>Stock Min <span class="text-danger">*</span></label>
                                <input type="text" id="txtSMin" name="txtSMin" placeholder="EJ. 5"
                                       class="touchspin-prefix" value="0" style="text-transform:uppercase;"
                                       onkeyup="javascript:this.value = this.value.toUpperCase();">
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="row">
                            <div class="col-sm-6">
                                <label>Categoria <span class="text-danger">*</span></label>
                                <select  data-placeholder="Seleccione una categoria..." id="cbCategoria" name="cbCategoria"
                                         class="select-search" style="text-transform:uppercase;"
                                         onkeyup="javascript:this.value = this.value.toUpperCase();">
                                        <?php
                                        $filas = $objProducto->Listar_Categorias();
                                        if (is_array($filas) || is_object($filas)) {
                                            foreach ($filas as $row => $column) {
                                                ?>
                                                <option value="<?php print ($column["idcategoria"]) ?>">
                                                <?php print ($column["nombre_categoria"]) ?></option>
                                                <?php
                                            }
                                        }
                                        ?>
                                </select>
                            </div>

                            <div class="col-sm-6">
                                <label>Marca</label>
                                <select  data-placeholder="Seleccione una categoria..." id="cbMarca" name="cbMarca"
                                         class="select-search" style="text-transform:uppercase;"
                                         onkeyup="javascript:this.value = this.value.toUpperCase();">
                                             <?php
                                             $filas = $objProducto->Listar_Marcas();
                                             if (is_array($filas) || is_object($filas)) {
                                                 foreach ($filas as $row => $column) {
                                                     ?>
                                            <option value="<?php print ($column["idmarca"]) ?>">
                                                     <?php print ($column["nombre_marca"]) ?></option>
                                                <?php
                                            }
                                        }
                                        ?>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="row">
                            <div class="col-sm-6" style= "display:none;">
                                <label>Presentacion <span class="text-danger">*</span></label>
                                <select  data-placeholder="Seleccione una presentacion..." id="cbPresentacion" name="cbPresentacion" value=1
                                         class="select-search" style="text-transform:uppercase;"
                                         onkeyup="javascript:this.value = this.value.toUpperCase();">
                                        !--<?php
                                        $filas = $objProducto->Listar_Presentaciones();
                                        if (is_array($filas) || is_object($filas)) {
                                            foreach ($filas as $row => $column) {
                                                $valorPorDefecto = 1;
                                                $selected = ($column["idpresentacion"] == $valorPorDefecto) ? 'selected="selected"' : '';
                                                ?>
                                            <option value="<?php print ($column["idpresentacion"]) ?>">
                                                     <?php print ($column["siglas"]) ?></option><?php
                                                 }
                                             }
                                             ?>-->
                                </select>
                            </div>
                            <div class="col-sm-9">
                                <label>Imagen</label>
                                <input type="file" id="txtImagen" name="txtImagen"
                                       class="form-control">
                            </div>
                            <div class="col-sm-3">
                            <label>Imagen Previa </label>
                            <img src="web/assets/images/no_img.jpg" class="img-thumbnail peditar" width="50px" height="40">
                            <input type="hidden" id="cimagen" name="cimagen">
                            </div>
                            
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="row">
                            <!--<div class="col-sm-4">
                                <div class="checkbox checkbox-switchery switchery-sm">
                                    <label>
                                        <input type="checkbox" id="chkPerece" name="chkPerece"
                                               class="switchery">
                                        <span id="lblchk-p">NO PERECEDERO</span>
                                    </label>
                                </div>
                            </div>-->

                            <div class="col-sm-4">
                                <div class="checkbox checkbox-switchery switchery-sm">
                                    <label>
                                        <input type="checkbox" id="chkExento" name="chkExento"
                                               class="switchery">
                                        <span id="lblchk-e">CON ITBMS</span>
                                    </label>
                                </div>
                            </div>

                            <div class="col-sm-4">
                                <div class="checkbox checkbox-switchery switchery-sm">
                                    <label>
                                        <input type="checkbox" id="chkInven" name="chkInven"
                                               class="switchery" checked="checked" >
                                        <span id="lblchk-i">INVENTARIABLE</span>
                                    </label>
                                </div>
                            </div>

                            <div class="col-sm-4" hidden="true">
                                <div class="checkbox checkbox-switchery switchery-sm">
                                    <label>
                                        <input type="checkbox" id="chkEstado" name="chkEstado"
                                               class="switchery" checked="checked" >
                                        <span id="lblchk">VIGENTE</span>
                                    </label>
                                </div>
                            </div>

                        </div>
                    </div>

                    <!--<div class="form-group">
                        <div class="row">
                            <div class="col-sm-4">
                                <div class="checkbox checkbox-switchery switchery-sm">
                                    <label>
                                        <input type="checkbox" id="chkEstado" name="chkEstado"
                                               class="switchery" checked="checked" >
                                        <span id="lblchk">VIGENTE</span>
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>-->


                </div>

                <div class="modal-footer">
                    <button id="btnGuardar" type="submit" class="btn btn-primary">Guardar</button>
                    <button id="btnEditar" type="submit" class="btn btn-warning">Editar</button>
                    <button  type="reset" class="btn btn-default" id="reset"
                             class="btn btn-link" data-dismiss="modal">Cerrar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Iconified modal -->
<div id="modal_iconified_barcode" class="modal fade">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h5 class="modal-title"><i class="icon-printer"></i> &nbsp; <span class="title-form"></span></h5>
            </div>

            <form role="form" autocomplete="off" class="form-validate-jquery" id="frmPrint">
                <div class="modal-body" id="modal-container">

                    <div class="alert alert-info alert-styled-left text-blue-800 content-group">
                        <span class="text-semibold">Estimado usuario</span>
                        Los campos remarcados con <span class="text-danger"> * </span> son necesarios.
                        <button type="button" class="close" data-dismiss="alert">×</button>
                        <input type="hidden" id="txtIDP" name="txtIDP" class="form-control" value="">
                    </div>

                    <div class="form-group">
                        <div class="row">
                            <div class="col-sm-6">
                                <label>Codigo Interno-Barra-Alternativo</label>
                                <div class="input-group">
                                    <span class="input-group-addon"><i class="icon-barcode2"></i></span>
                                    <input type="text" id="txtCodigoBarraP" name="txtCodigoBarraP"
                                           placeholder="0108580848408"
                                           class="form-control" style="text-transform:uppercase;"
                                           onkeyup="javascript:this.value = this.value.toUpperCase();">
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="row">
                            <div class="col-sm-12">
                                <label>Producto <span class="text-danger">*</span></label>
                                <input type="text" id="txtProductoP" name="txtProductoP" placeholder="EJ. MOUSE RAZER"
                                       class="form-control" style="text-transform:uppercase;"
                                       onkeyup="javascript:this.value = this.value.toUpperCase();">
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="row">
                            <div class="col-sm-6">
                                <label>Cantidad de etiquetas<span class="text-danger">*</span></label>
                                <input type="text" id="txtCant" name="txtCant" placeholder="0"
                                       class="touchspin-prefix" style="text-transform:uppercase;"
                                       onkeyup="javascript:this.value = this.value.toUpperCase();">
                            </div>

                        </div>
                    </div>

                    <div class="form-group">
                        <div class="row">

                            <div class="col-sm-6">
                                <label>Ancho de etiqueta (mm)<span class="text-danger">*</span></label>
                                <input type="text" id="txtAncho" name="txtAncho"
                                       placeholder="EJ. 14.00"
                                       class="touchspin-prefix" style="text-transform:uppercase;"
                                       onkeyup="javascript:this.value = this.value.toUpperCase();">
                            </div>

                            <div class="col-sm-6">
                                <label>Alto de etiqueta (mm)<span class="text-danger">*</span></label>
                                <input type="text" id="txtAlto" name="txtAlto"
                                       placeholder="EJ. 1.00"
                                       class="touchspin-prefix" style="text-transform:uppercase;"
                                       onkeyup="javascript:this.value = this.value.toUpperCase();">
                            </div>

                        </div>
                    </div>


                </div>

                <div class="modal-footer">
                    <button id="btnPrint" type="submit" class="btn btn-info">Imprimir</button>
                    <button  type="reset" class="btn btn-default" id="reset"
                             class="btn btn-link" data-dismiss="modal">Cerrar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal Historial -->
<div id="modal_historial" class="modal fade" tabindex="-1">
    <div class="modal-dialog" style="width: 90vw; height: 90vh;">
        <div class="modal-content">
            <div class="modal-header bg-primary">
                <h5 class="modal-title">Historial</h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>

            <div id="reload-div">
                <table class="table datatable-basic table-borderless table-hover table-lg" style="table-layout: fixed; width: 100%;">
                    <thead>
                        <tr>
                            <th style="white-space: nowrap;">N° Historial</th>
                            <th>C.Interno</th>
                            <th>C.Barra</th>
                            <th>C.Alter</th>
                            <th>Producto</th>
                            <th style="white-space: nowrap; word-wrap: break-word; white-space: normal; min-width: 250px;">Tipo de Movimiento</th>
                            <th>S.Actual</th>
                            <th>S.Antes</th>
                            <th>Fecha</th>
                            <th>Usuario</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php
                        $filas = $objProducto->Listar_Historial();
                        if (is_array($filas) || is_object($filas)) {
                            foreach ($filas as $row => $column) {              
                                ?>
                                <tr>
                                    <td style="white-space: nowrap;"><?php print($column['num_historial']); ?></td>
                                    <td style="white-space: nowrap;"><?php print($column['codigo_interno']); ?></td>
                                    <td style="white-space: nowrap;"><?php print($column['codigo_barra']); ?></td>
                                    <td style="white-space: nowrap;"><?php print($column['codigo_alternativo']); ?></td>
                                    <td style="white-space: nowrap; word-wrap: break-word; white-space: normal; min-width: 200px;"><?php print($column['nombre_producto']); ?></td>
                                    <td style="white-space: nowrap; word-wrap: break-word; white-space: normal; min-width: 300px;"><?php print($column['tipo_movimiento']); ?></td>
                                    <td style="white-space: nowrap;"><?php print($column['stock_actual']); ?></td>
                                    <td style="white-space: nowrap;"><?php print($column['stock_anterior']); ?></td>
                                    <td style="white-space: nowrap;"><?php print($column['fecha_movimiento']); ?></td>
                                    <td style="white-space: nowrap;"><?php print($column['usuario']); ?></td>
                                </tr>
                                <?php
                            }
                        }
                        ?>
                    </tbody>
                </table>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-link" data-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>


<input type="file" id="archivo_input" accept=".csv" style="display: none;">
<input type="file" id="archivo_excel" accept=".xls,.xlsx" style="display:none;" />

<script type="text/javascript" src="web/custom-js/producto.js"></script>