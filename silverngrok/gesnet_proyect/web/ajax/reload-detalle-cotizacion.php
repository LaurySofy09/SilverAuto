

<?php
	session_start();
	spl_autoload_register(function($className){
		$model = "../../model/". $className ."_model.php";
		$controller = "../../controller/". $className ."_controller.php";

		require_once($model);
		require_once($controller);

	});


	$idcotizacion = isset($_GET['numero_transaccion']) ? $_GET['numero_transaccion'] : '';
  $objVenta = new Venta();
	$objCotizacion =  new Cotizacion();
	$detalle = $objCotizacion->Listar_Detalle($idcotizacion);
	$info = $objCotizacion->Listar_Info($idcotizacion);

	foreach ($info as $row => $column) {

		$numero_cotizacion = $column["numero_cotizacion"];
		$fecha_cotizacion = $column["fecha_cotizacion"];
		$tipo_pago = $column["tipo_pago"];
		$a_nombre = $column["a_nombre"];
		$entrega = $column["entrega"];
		$sumas = $column["sumas"];
		$iva = $column["iva"];
		$subtotal = $column["subtotal"];
		$total_exento = $column["total_exento"];
		$retenido = $column["retenido"];
		$total_descuento = $column["total_descuento"];
		$total = $column["total"];
	}


?>
 
	<!-- Collapsible with right control button -->
	<input type="hidden" name="hiddenCotiza" id="hiddenCotiza" value="<?php echo $idcotizacion; ?>">
	<div class="panel-group panel-group-control panel-group-control-right content-group-lg">
		<div class="panel">
			<div class="panel-heading bg-info">
				<h6 class="panel-title">
					<a class="collapsed" data-toggle="collapse" href="#collapsible-control-right-group2">Clic para ver Información de la Cotizacion</a>
				</h6>
			</div>
			<div id="collapsible-control-right-group2" class="panel-collapse collapse">
				<div class="panel-body">
					<div class="table-responsive">
            <table class="table table-xxs table-bordered">
             <tbody class="border-solid">
             <tr>
              <td width="5%" class="text-bold text-left">NO. COTIZACION</td>
              <td width="35%"><?php echo $numero_cotizacion; ?></td>
              <td width="2%" class="text-bold text-left">FORMA PAGO</td>
              <td width="30%"><?php echo $tipo_pago; ?></td>
             </tr>
            <tr>
              <td width="5%" class="text-bold text-left">A NOMBRE DE </td>
              <td width="30%"><?php echo $a_nombre; ?></td>
              <td width="2%" class="text-bold text-left">FECHA</td>
              <td width="30%"><?php echo DateTime::createFromFormat('Y-m-d H:i:s', $fecha_cotizacion)->format('d/m/Y H:i:s'); ?></td>
            </tr>
            <tr>
              <td width="20%" class="text-bold text-left">FORMA DE ENTREGA</td>
              <td width="5%"><?php echo $entrega ?></td>
              <td width="10%" class="text-bold text-left">TOTAL</td>
              <td width="5%"><?php echo $total ?></td>
            </tr>
            </tbody>
          </table>
				 </div>
				 <div class="text-right">
					 <!--<button style="margin-top: 10px; font-size: 15px;" id="btnFacturar" class="btn btn-success btn-sm" data-toggle="modal" data-target="#modal_iconified_cash">
					 	<i class="fa fa-shopping-bag"></i> Facturar</button> -->
					 	<button style="margin-top: 10px; font-size: 15px;" id="btnFacturar" class="btn btn-success btn-sm" data-toggle="modal" data-target="#modal_iconified_cash" type="button">
						    <i class="fa fa-shopping-bag"></i> Facturar
						</button>

					</div> 
				</div>
			</div>
		</div>
	</div>
	<!-- /collapsible with right control button -->
	<!-- Iconified modal -->
				<div id="modal_iconified_cash" class="modal fade">
					<div class="modal-dialog">
						<div class="modal-content">
							<div class="modal-header">
								<button type="button" class="close" data-dismiss="modal">&times;</button>
								<h5 class="modal-title"><i class="icon-cash"></i> &nbsp; <span class="title-form">Facturar Venta</span></h5>
							</div>

					    <form role="form" autocomplete="off" class="form-validate-jquery" id="frmPago">
								<div class="modal-body" id="modal-container">

									<div class="form-group">
										<div class="row">
											<div class="col-sm-8">
												<label>Seleccione el Cliente</label>
												<select  data-placeholder="..." id="cbClienteCot" name="cbClienteCot"
													class="select-size-xs" style="text-transform:uppercase;"
				                   onkeyup="javascript:this.value=this.value.toUpperCase();" readonly="readonly" disabled="disabled">
													 
			                            			  <?php
														$cotizador = $objCotizacion->Mostrar_Cliente($idcotizacion);
														if (is_array($cotizador) || is_object($cotizador))
														{
														$column = reset($cotizador);
														{
														?>
															<option selected value="<?php print ($column["idcliente"])?>">
															<?php print ($column["idcliente"].' - '.
															 $column["a_nombre"])?></option>
														<?php
															}
														}
														 ?>

												 </select>
											</div>

											<div class="col-sm-4">
													<label>Limite Crediticio <span class="text-danger"></span></label>
														<div class="input-group">
														<span class="input-group-addon"><i class="icon-cash3"></i></span>
														<input type="text" id="txtLimitCot" name="txtLimitCot" placeholder="0.00"
														 class="form-control" style="text-transform:uppercase;"
															onkeyup="javascript:this.value=this.value.toUpperCase();" readonly="readonly" disabled="disabled">
															
														</div>
												</div>

										</div>
									</div>


						    <div class="form-group" style="display:none;">
									<div class="row">

										<div class="col-sm-6">
											<label>Seleccione la condicion de pago</label>
											<div class="checkbox checkbox-switchery switchery-sm">
												<label>
												<input type="checkbox" id="chkPagadoCot" name="chkPagadoCot"
												 class="switchery" checked="checked" >
												 <span id="lblchk2Cot">VENTA AL CONTADO</span>
											   </label>
											</div>
										</div>

										<div class="col-sm-6">
											<label>Seleccione comprobante de Venta</label>
											<select  data-placeholder="..." id="cbCompro" name="cbCompro"
												class="select-size-xs" style="text-transform:uppercase;"
												onkeyup="javascript:this.value=this.value.toUpperCase();">
																				<?php
													$filas = $objVenta->Listar_Comprobantes();
													if (is_array($filas) || is_object($filas))
													{
													foreach ($filas as $row => $column)
													{
													?>
														<option value="<?php print ($column["idcomprobante"])?>">
														<?php print ($column["nombre_comprobante"])?></option>
													<?php
														}
													}
													 ?>
											 </select>
										</div>

									</div>
								</div>

								<div class="form-group" style="display:none;">
									<div class="row">

										<div id="div-cbMPago" class="col-sm-6">
										 <label>Metodo de Pago</label>
											 <select id="cbMPago" name="cbMPago" data-placeholder="Seleccione un metodo de pago..." class="select-icons">
													 <option value="1" data-icon="cash">EFECTIVO</option>
													 <option value="2" data-icon="credit-card">TARJETA DE DEBITO / CREDITO</option>
													 <option value="3" data-icon="cash4">EFECTIVO</option>
													 <option value="4" data-icon="bubbles">YAPPY</option>
													 <option value="5" data-icon="price-tags">NEQUI</option>
													 <option value="6" data-icon="file-text2">CHEQUE</option>
											 </select>
										</div>
									</div>
								</div>


								<div class="form-group">
									<div class="row">
											<div class="col-sm-4">
													<label>A Pagar <span class="text-danger"> * </span></label>
													<div class="input-group">
													<span class="input-group-addon"><i class="icon-cash3"></i></span>
													<input type="text" id="txtDeuda" name="txtDeuda" placeholder="0.00"
													 class="form-control input-sm" style="text-transform:uppercase;"
			                     onkeyup="javascript:this.value=this.value.toUpperCase();"
													 readonly="readonly" disabled="disabled">
			                 	</div>
											</div>

										<div id="div-txtMonto" class="col-sm-4" style="display:none;">
											<label>Efectivo Recibido <span class="text-danger"> * </span></label>
											<input type="text" id="txtMonto" name="txtMonto" placeholder="0.00"
											 class="form-control input-sm" style="text-transform:uppercase;"
	                     onkeyup="javascript:this.value=this.value.toUpperCase();">
										</div>

											<div id="div-txtCambio" class="col-sm-4" style="display:none;">
													<label>Cambio <span class="text-danger"> * </span></label>
													<div class="input-group">
													<span class="input-group-addon"><i class="icon-cash"></i></span>
													<input type="text" id="txtCambio" name="txtCambio" placeholder="0.00"
													 class="form-control input-sm" style="text-transform:uppercase;"
		                  		onkeyup="javascript:this.value=this.value.toUpperCase();"
													readonly="readonly" disabled="disabled">
		                  </div>
										</div>
									</div>
								</div>

								<div class="form-group">
									<div class="row">
											<div id="div-txtNoTarjeta" class="col-sm-5">
													<label> Tarjeta Debito/Credito <span class="text-danger"> * </span></label>
													<div class="input-group">
													<span class="input-group-addon"><i class="icon-credit-card"></i></span>
													<input type="text" id="txtNoTarjeta" name="txtNoTarjeta" placeholder="numero de tarjeta"
													 class="form-control input-sm" style="text-transform:uppercase;"
													 onkeyup="javascript:this.value=this.value.toUpperCase();">
												</div>
											</div>

											<div id="div-txtHabiente" class="col-sm-7">
													<label> Tarjeta Habiente <span class="text-danger"> * </span></label>
													<div class="input-group">
													<span class="input-group-addon"><i class="icon-user"></i></span>
													<input type="text" id="txtHabiente" name="txtHabiente" placeholder="Juan Perez"
													 class="form-control input-sm" style="text-transform:uppercase;"
													 onkeyup="javascript:this.value=this.value.toUpperCase();">
												</div>
											</div>
									</div>
								</div>

								<div class="form-group">
									<div class="row">
											<div id="div-txtMontoTar" class="col-sm-5">
													<label> Monto Debitado <span class="text-danger"> * </span></label>
													 <input type="text" id="txtMontoTar" name="txtMontoTar" placeholder="0.00"
													 class="touchspin-prefix" value="0" style="text-transform:uppercase;"
													 onkeyup="javascript:this.value=this.value.toUpperCase();">
												</div>
									</div>
								</div>


								</div>

								<div class="modal-footer">
									<button  type="reset" class="btn btn-default" id="reset"
									class="btn btn-link" data-dismiss="modal">Cerrar</button>
									<button type="submit" id="btnRegistrar" class="btn bg-success-800 btn-labeled"><b><i class="icon-printer4"></i>
									</b> Enviar a caja</button>
								</div>
							</form>
						</div>
					</div>
				</div>
				<!-- /iconified modal -->

	<div class="panel-group panel-group-control panel-group-control-right content-group-lg">
		<div class="table-responsive">
			<table id="tbldetalle" class="table table-borderless table-striped table-xxs">
				<thead>
					<tr class="bg-blue">
            <th>Producto</th>
            <th>Cant.</th>
            <th>Precio</th>
            <th>Tot. SIN ITBMS</th>
            <th>Descuento</th>
            <th>Importe</th>
            <th>Disponible</th>
					</tr>
				</thead>
				<tbody>

				 <?php
					if (is_array($detalle) || is_object($detalle))
					{
					foreach ($detalle as $row => $column)
					{

						$disponible = $column["disponible"];
						$productos = $column["idproducto"];

						if($disponible=="0"){
							$disponible = "NO";
						} else {
							$disponible = "SI";
						}

					?>
						<tr>
								<td style="display: none;"><?php print($column['idproducto']); ?></td>
              	<td><?php print($column['nombre_producto']); ?></td>
              	<td><?php print($column['cantidad']); ?></td>
              	<td><?php print($column['precio_unitario']); ?></td>
              	<td><?php print($column['exento']); ?></td>
              	<td><?php print($column['descuento']); ?></td>
              	<td><?php print($column['importe']); ?></td>
              	<td><?php print($disponible); ?></td>
            </tr>
					<?php

					}
				}

						/*$productos = '';
						if (is_array($detalle) && count($detalle) > 0) {
					    foreach ($detalle as $column) {
					        $productos .= $column['idproducto'] . "|";
					    }

						}
						$_SESSION['ver_productos'] = $productos;*/

				 ?>

				</tbody>
				<tfoot>
					<tr>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td width="10%">SUMAS</td>
						<td id="sumas"><?php echo $sumas; ?></td>
						<td></td>
					</tr>
					<tr>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td width="10%">ITBMS %</td>
						<td id="iva"><?php echo $iva; ?></td>
						<td></td>
					</tr>
					<tr>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td width="10%">SUBTOTAL</td>
						<td id="subtotal"><?php echo $subtotal; ?></td>
						<td></td>
					</tr>
					<tr>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td width="10%">RET. (-)</td>
						<td id="ivaretenido"><?php echo $retenido; ?></td>
						<td></td>
					</tr>
					<tr>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td width="10%">TOT. SIN ITBMS</td>
						<td id="exentas"><?php echo $total_exento; ?></td>
						<td></td>
					</tr>
					<tr>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td width="10%">DESCUENTO</td>
						<td id="descuentos"><?php echo $total_descuento; ?></td>
						<td></td>
					</tr>
					<tr>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td width="10%">TOTAL</td>
						<td id="total"><?php echo $total; ?></td>
						<td></td>
					</tr>
				</tfoot>
			</table>
		</div>
        <input type="hidden" id="hdnApagar" name="hdnApagar" />
	</div>

	<script type="text/javascript" src="web/custom-js/cotizaciones_modal.js"></script>
	<script type="text/javascript">
		$("#chkPagadoCot").change(function() {
   if(this.checked) {
      $("#chkPagadoCot").val(true);
      document.getElementById("lblchk2Cot").innerHTML = 'VENTA AL CONTADO';
      $("#txtMonto").val('');
      $("#txtCambio").val('');
      Venta_Contado();
   } else {
     $("#chkPagadoCot").val(false);
     document.getElementById("lblchk2Cot").innerHTML = 'VENTA AL CREDITO';
     $("#txtMonto").val('0.00');
     $("#txtCambio").val('0.00');
     Venta_Credito();
   }
})
        
         $("#hdnApagar").val('<?php echo $total; ?>');
	</script>
