<?php

  if($tipo_usuario==1 || $tipo_usuario==4){

  	$objTaller= new Taller();
    $objVenta = new Venta();
    $objProducto = new Producto();

  	$count_ordenes = $objTaller->Count_Ordenes('','');

  	foreach ($count_ordenes as $row => $column) {
  		$total_ordenes = $column["total_ordenes"];
  	}


 ?>

  	<script type="text/javascript" src="web/custom-js/taller.js?op=<?=time()?>"></script>
			<!-- Labels -->
			<div class="row">
				<div class="col-lg-12">
					<div class="panel panel-flat">
						<div class="breadcrumb-line">
							<ul class="breadcrumb">
								<li><a href="?View=Inicio"><i class="icon-home2 position-left"></i> Inicio</a></li>
								<li><a href="javascript:;"> Taller </a></li>
								<li class="active">Ordenes de Taller</li>
							</ul>
						</div>
						<div class="panel-heading">
							<div class="row">
								<div class="col-sm-6 col-md-5">
								 <form role="form" autocomplete="off" class="form-validate-jquery" id="frmSearch">
									 <div class="form-group">
										 <div class="row">
											 <div class="col-sm-5">
												 <div class="input-group">
												 <span class="input-group-addon"><i class="icon-calendar3"></i></span>
												 <input type="text" id="txtF1" name="txtF1" placeholder=""
													class="form-control input-sm" style="text-transform:uppercase;"
																 onkeyup="javascript:this.value=this.value.toUpperCase();">
																 </div>
											 </div>
											 <div class="col-sm-5">
												 <div class="input-group">
												 <span class="input-group-addon"><i class="icon-calendar3"></i></span>
												 <input type="text" id="txtF2" name="txtF2" placeholder=""
													class="form-control input-sm" style="text-transform:uppercase;"
																 onkeyup="javascript:this.value=this.value.toUpperCase();">
																 </div>
											 </div>
											 <div class="col-sm-2">
												 <button style="margin-top: 0px;" id="btnGuardar"
												 type="submit" class="btn btn-primary btn-sm">
												 <i class="icon-search4"></i> Consultar</button>
											 </div>
										 </div>
									 </div>
									 </form>
									 </div>
							 </div>

						</div>

					<div id="reload-div">
						<div class="panel-body">
							<div class="tabbable">
								<ul class="nav nav-tabs nav-tabs-highlight">
									<li class="active"><a href="#label-tab1" data-toggle="tab">ORDENES REALIZADAS <span id="span-ing" class="label
									label-success position-right"><?php echo $total_ordenes  ?></span></a></li>
								</ul>

								<div class="tab-content">

									<div class="tab-pane active" id="label-tab1">
										<!-- Basic initialization -->
										<div class="panel panel-flat">
											<div class="panel-heading">
												<h5 class="panel-title">Ordenes de Taller</h5>
												<div class="heading-elements">

                          <button type="button" class="btn btn-primary heading-btn"
            							onclick="newOrden()">
            							<i class="icon-database-add"></i> Agregar Nuevo/a</button>

												</div>
											</div>
												<div class="panel-body">
													<table class="table datatable-basic table-xs table-hover">
														<thead>
															<tr>
                                                                <th>Fecha de Ingreso</th>
																<th>Orden</th>
																<th>Cliente</th>
																<th>Placa</th>
																<th>Marca</th>
																<th>Averia</th>
																<th>Opciones</th>
															</tr>
														</thead>

														<tbody>

														  <?php
																$filas = $objTaller->Listar_Ordenes('','');
																if (is_array($filas) || is_object($filas))
																{
																foreach ($filas as $row => $column)
																{

																	$fecha_ingreso = $column["fecha_ingreso"];
																	if(is_null($fecha_ingreso))
																	{
																		$c_fecha_ingreso = '';

																	} else {

																		$c_fecha_ingreso = DateTime::createFromFormat('Y-m-d H:i:s',$fecha_ingreso)->format('d/m/Y H:i:s');
																	}

                                  $fecha_alta = $column["fecha_alta"];
                                  if(is_null($fecha_alta))
                                  {
                                    $c_fecha_alta = '';

                                  } else {

                                    $c_fecha_alta = DateTime::createFromFormat('Y-m-d H:i:s',$fecha_alta)->format('d/m/Y H:i:s');
                                  }


                                  $fecha_retiro = $column["fecha_retiro"];
                                  if(is_null($fecha_retiro))
                                  {
                                    $c_fecha_retiro = '';

                                  } else {

                                    $c_fecha_retiro = DateTime::createFromFormat('Y-m-d H:i:s',$fecha_retiro)->format('d/m/Y H:i:s');
                                  }

																?>
																	<tr>
																		  <td><?php print($c_fecha_ingreso); ?></td>
                                      <td><?php print($column['numero_orden']); ?></td>
																			<td><?php print($column['nombre_cliente']); ?></td>
										                	<td><?php print($column['Placa']); ?></td>
										                	<td><?php print($column['nombre_marca']); ?></td>
																			<td><?php print($column['averia']); ?></td>

																		<td class="text-center">
																			<ul class="icons-list">
																				<li class="dropdown">
																					<a href="#" class="dropdown-toggle" data-toggle="dropdown">
																						<i class="icon-menu9"></i>
																					</a>
																					<ul class="dropdown-menu dropdown-menu-right">

                                          <?php if($column["diagnostico"] == ''): ?>

												<li><a href="javascript:;" data-toggle="modal" data-target="#modal_iconified2"
																		 onclick="openOrden('diagnostico',
																			  '<?php print($column["idorden"]); ?>',
                                                   '<?php print($column["numero_orden"]); ?>',
                                                   '<?php print($c_fecha_ingreso); ?>',
                                                   '<?php print($column["idcliente"]); ?>',
                                                   '<?php print($column["Placa"]); ?>',
                                                   '<?php print($column["AnioAuto"]); ?>',
                                                   '<?php print($column["modelo"]); ?>',
                                                   '<?php print($column["idmarca"]); ?>',
                                                   '<?php print($column["serie"]); ?>',
                                                   '<?php print($column["idtecnico"]); ?>',
                                                   '<?php print($column["averia"]); ?>',
                                                   '<?php print($column["observaciones"]); ?>',
                                                   '<?php print($column["deposito_revision"]); ?>',
                                                   '<?php print($column["deposito_reparacion"]); ?>',
                                                   '<?php print($column["diagnostico"]); ?>',
                                                   '<?php print($column["estado_aparato"]); ?>',
                                                   '<?php print($column["repuestos"]); ?>',
                                                   '<?php print($column["mano_obra"]); ?>',
                                                   '<?php print($c_fecha_alta); ?>',
                                                   '<?php print($c_fecha_retiro); ?>',
                                                   '<?php print($column["ubicacion"]); ?>',
                                                   '<?php print($column["parcial_pagar"]); ?>',
                                                   '<?php print($column["montoRepuesto"]); ?>',
                                                   '<?php print($column["ManoObra"]); ?>',
                                                   '<?php print($column["horaObra"]); ?>')">
																			<i class="icon-wrench">
																			</i> Hacer Diagnostico</a></li>

                                                <li><a href="javascript:;" data-toggle="modal" data-target="#modal_iconified"
                                                   onclick="openOrden('informacion-editar',
                                                     '<?php print($column["idorden"]); ?>',
                                                     '<?php print($column["numero_orden"]); ?>',
                                                     '<?php print($c_fecha_ingreso); ?>',
                                                     '<?php print($column["idcliente"]); ?>',
                                                     '<?php print($column["Placa"]); ?>',
                                                     '<?php print($column["AnioAuto"]); ?>',
                                                     '<?php print($column["modelo"]); ?>',
                                                     '<?php print($column["idmarca"]); ?>',
                                                     '<?php print($column["serie"]); ?>',
                                                     '<?php print($column["idtecnico"]); ?>',
                                                     '<?php print($column["averia"]); ?>',
                                                     '<?php print($column["observaciones"]); ?>',
                                                     '<?php print($column["deposito_revision"]); ?>',
                                                     '<?php print($column["deposito_reparacion"]); ?>',
                                                     '<?php print($column["diagnostico"]); ?>',
                                                     '<?php print($column["estado_aparato"]); ?>',
                                                     '<?php print($column["repuestos"]); ?>',
                                                     '<?php print($column["mano_obra"]); ?>',
                                                     '<?php print($c_fecha_alta); ?>',
                                                     '<?php print($c_fecha_retiro); ?>',
                                                     '<?php print($column["ubicacion"]); ?>',
                                                     '<?php print($column["parcial_pagar"]); ?>',
                                                   '<?php print($column["montoRepuesto"]); ?>',
                                                   '<?php print($column["ManoObra"]); ?>',
                                                   '<?php print($column["horaObra"]); ?>')">
                                                    <i class="icon-pencil3">
                                                    </i> Editar Informacion</a></li>

                                            <?php else: ?>

                                              <li><a href="javascript:;" data-toggle="modal" data-target="#modal_iconified"
                                                 onclick="openOrden('informacion-editar',
                                                   '<?php print($column["idorden"]); ?>',
                                                   '<?php print($column["numero_orden"]); ?>',
                                                   '<?php print($c_fecha_ingreso); ?>',
                                                   '<?php print($column["idcliente"]); ?>',
                                                   '<?php print($column["Placa"]); ?>',
                                                   '<?php print($column["AnioAuto"]); ?>',
                                                   '<?php print($column["modelo"]); ?>',
                                                   '<?php print($column["idmarca"]); ?>',
                                                   '<?php print($column["serie"]); ?>',
                                                   '<?php print($column["idtecnico"]); ?>',
                                                   '<?php print($column["averia"]); ?>',
                                                   '<?php print($column["observaciones"]); ?>',
                                                   '<?php print($column["deposito_revision"]); ?>',
                                                   '<?php print($column["deposito_reparacion"]); ?>',
                                                   '<?php print($column["diagnostico"]); ?>',
                                                   '<?php print($column["estado_aparato"]); ?>',
                                                   '<?php print($column["repuestos"]); ?>',
                                                   '<?php print($column["mano_obra"]); ?>',
                                                   '<?php print($c_fecha_alta); ?>',
                                                   '<?php print($c_fecha_retiro); ?>',
                                                   '<?php print($column["ubicacion"]); ?>',
                                                   '<?php print($column["parcial_pagar"]); ?>',
                                                   '<?php print($column["montoRepuesto"]); ?>',
                                                   '<?php print($column["ManoObra"]); ?>',
                                                   '<?php print($column["horaObra"]); ?>')">
                                                  <i class="icon-pencil3">
                                                  </i> Editar Informacion</a></li>

                                              <li><a href="javascript:;" data-toggle="modal" data-target="#modal_iconified2"
                                                 onclick="openOrden('diagnostico-editar',
                                                   '<?php print($column["idorden"]); ?>',
                                                   '<?php print($column["numero_orden"]); ?>',
                                                   '<?php print($c_fecha_ingreso); ?>',
                                                   '<?php print($column["idcliente"]); ?>',
                                                   '<?php print($column["Placa"]); ?>',
                                                   '<?php print($column["AnioAuto"]); ?>',
												   '<?php print($column["modelo"]); ?>',
                                                   '<?php print($column["idmarca"]); ?>',
                                                   '<?php print($column["serie"]); ?>',
                                                   '<?php print($column["idtecnico"]); ?>',
                                                   '<?php print($column["averia"]); ?>',
                                                   '<?php print($column["observaciones"]); ?>',
                                                   '<?php print($column["deposito_revision"]); ?>',
                                                   '<?php print($column["deposito_reparacion"]); ?>',
                                                   '<?php print($column["diagnostico"]); ?>',
                                                   '<?php print($column["estado_aparato"]); ?>',
                                                   '<?php print($column["repuestos"]); ?>',
                                                   '<?php print($column["mano_obra"]); ?>',
                                                   '<?php print($c_fecha_alta); ?>',
                                                   '<?php print($c_fecha_retiro); ?>',
                                                   '<?php print($column["ubicacion"]); ?>',
                                                   '<?php print($column["parcial_pagar"]); ?>',
                                                   '<?php print($column["montoRepuesto"]); ?>',
                                                   '<?php print($column["ManoObra"]); ?>',
                                                   '<?php print($column["horaObra"]); ?>')">
                                                  <i class="icon-pencil">
                                                  </i> Editar Diagnostico</a></li>


                                            <?php endif; ?>


                                               <li><a href="javascript:;" data-toggle="modal" data-target="#modal_ticket"
                                               onclick="Print_Ticket('<?php print($column["idorden"]); ?>')">
                                                <i class="icon-printer">
                                                </i> Imprimir Ticket </a></li>


																							 <li><a id="print_invoice"
																							data-id="<?php print($column['idorden']); ?>"
																							href="javascript:void(0)">
																						 	<i class="icon-printer2">
																							</i> Imprimir Boleta</a></li>

																							<li><a id="delete_product"
																							data-id="<?php print($column['idorden']); ?>"
																							href="javascript:void(0)">
																							<i class=" icon-trash">
																							</i> Borrar</a></li>

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
													</table>
												</div>
											</div>
									</div>


								</div>
							</div>
						</div>
					</div>

          <!-- Iconified modal -->
      			<div id="modal_iconified" class="modal fade">
      				<div class="modal-dialog modal-lg">
      					<div class="modal-content">
      						<div class="modal-header">
      							<button type="button"  id="btnclose" class="close" data-dismiss="modal">&times;</button>
      							<h5 class="modal-title"><i class="icon-pencil7"></i> &nbsp; <span class="title-form"></span></h5>
      						</div>
                  <div class="modal-body" id="modal-container">
                    <!-- Basic tabs -->
                      <div class="row">
                        <div class="col-md-12">
                          <div class="panel panel-flat">
                            <div class="panel-body">
                              <div class="alert alert-info alert-styled-left text-blue-800 content-group">
                                    <span class="text-semibold">Estimado usuario</span>
                                    Los campos remarcados con <span class="text-danger"> * </span> son necesarios..
                                    <button type="button" class="close" data-dismiss="alert">×</button>
                               </div>
                                      <form role="form" autocomplete="off" class="form-validate-jquery" id="frmInformacion">
                                        <input type="hidden" id="txtProceso_I" name="txtProceso_I" class="form-control" value="">
                                        <input type="hidden" id="txtID_I" name="txtID_I" class="form-control" value="">
                                        <fieldset>
                                          <legend class="text-semibold">
                      												<i class="icon-file-text2 position-left"></i>
                      												Detalles
                      											</legend>
                                           <div class="form-group">
                              								<div class="row">
                              										<div class="col-sm-6">
                              											<label>No. Orden</label><span class="text-danger"> *</span>
                              											<input type="text" id="txtNoOrden" name="txtNoOrden" placeholder="AUTOGENERADO"
                              											 class="form-control" style="text-transform:uppercase;"
                                                      onkeyup="javascript:this.value=this.value.toUpperCase();">
                              										</div>
                                                
                                                
                                                <div class="col-sm-6">
                                                    <label>Cliente <span class="text-danger">*</span></label>
                                                    <select  data-placeholder="Seleccione una cliente..." id="cbCliente" name="cbCliente"
                                                      class="select-search" style="text-transform:uppercase;"
                                                      onkeyup="javascript:this.value=this.value.toUpperCase();">
                                                      <?php
                                                         $filas = $objVenta->Listar_Clientes();
                                                         if (is_array($filas) || is_object($filas))
                                                         {
                                                         foreach ($filas as $row => $column)
                                                         {
                                                         ?>
                                                           <option value="<?php print ($column["idcliente"])?>">
                                                           <?php print ($column["nombre_cliente"])?></option>
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
                                               
                                                
                                                </div>
                                            </div>
                                                
                                            <div class="form-group">
                                                <div class="row">
                                                  <div class="col-sm-4" style="display:none;">
                              											<label>Aparato <span class="text-danger">*</span></label>
                              											<input type="text" id="txtAparato" name="txtAparato" placeholder="EJ. LAPTOP"
                              											 class="form-control" style="text-transform:uppercase;"
                                                    onkeyup="javascript:this.value=this.value.toUpperCase();">
                              										</div>

                                                  <div class="col-sm-4">
                                                    <label>Marca</label>
                                                    <select  data-placeholder="Seleccione una marca..." id="cbMarca" name="cbMarca"
                                                      class="select-search" style="text-transform:uppercase;"
                                                      onkeyup="javascript:this.value=this.value.toUpperCase();">
                                                      <?php
                                                         $filas = $objProducto->Listar_Marcas();
                                                         if (is_array($filas) || is_object($filas))
                                                         {
                                                         foreach ($filas as $row => $column)
                                                         {
                                                         ?>
                                                           <option value="<?php print ($column["idmarca"])?>">
                                                           <?php print ($column["nombre_marca"])?></option>
                                                         <?php
                                                           }
                                                         }
                                                          ?>
                                                      </select>
                                                  </div>

                                                  <div class="col-sm-4">
                                                        <label>Modelo<span class="text-danger">*</span></label>
                                                     <input type="text" id="txtModelo" name="txtModelo" placeholder="EJ. Q5"
                                                      class="form-control"  style="text-transform:uppercase;"
                                                     onkeyup="javascript:this.value=this.value.toUpperCase();">
                                                  </div>
                                                
                                                <div class="col-sm-4">
                                                        <label>Año<span class="text-danger">*</span></label>
                                                     <input type="text" id="txtAnio" name="txtAnio" placeholder="2023"
                                                      class="form-control EnteroSinCero"  style="text-transform:uppercase;"
                                                     onkeyup="javascript:this.value=this.value.toUpperCase();">
                                                  </div>

                                                </div>
                                            </div>

                                            <div class="form-group">
                                              <div class="row">

                                                <div class="col-sm-4">
                                                  <label>Placa</label>
                                                  <input type="text" id="txtPlaca" name="txtPlaca" placeholder="AB00000"
                                                   class="form-control"  style="text-transform:uppercase;"
                                                  onkeyup="javascript:this.value=this.value.toUpperCase();">
                                                </div>

                                                <div class="col-sm-8">
                                                  <label>Tecnico <span class="text-danger">*</span></label>
                                                  <select  data-placeholder="Seleccione un tecnico..." id="cbTecnico" name="cbTecnico"
                                                    class="select-search" style="text-transform:uppercase;"
                                                    onkeyup="javascript:this.value=this.value.toUpperCase();">
                                                    <?php
                                                    $filas = $objTaller-> Listar_Tecnicos();
                                                     if (is_array($filas) || is_object($filas))
                                                     {
                                                     foreach ($filas as $row => $column)
                                                     {
                                                     ?>
                                                       <option value="<?php print ($column["idtecnico"])?>">
                                                       <?php print ($column["tecnico"])?></option>
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
                                                  <div class="col-sm-6">
                                                    <label>Averia <span class="text-danger">*</span></label>
                                                     <textarea rows="2" class="form-control"
                                                      placeholder="EJ. AMORTIGUADORES EN MAL ESTADO" id="txtAveria" name="txtAveria"
                                                      value="" style="text-transform:uppercase;"
                                                      onkeyup="javascript:this.value=this.value.toUpperCase();">
                                                      </textarea>
                                                  </div>

                                                  <div class="col-sm-6">
                                                    <label>Observaciones <span class="text-danger">*</span></label>
                                                     <textarea rows="2" class="form-control"
                                                      placeholder="..." id="txtObservaciones" name="txtObservaciones"
                                                      value="" style="text-transform:uppercase;"
                                                      onkeyup="javascript:this.value=this.value.toUpperCase();">
                                                      </textarea>
                                                  </div>
                                                </div>
                                            </div>


                                          <legend class="text-semibold" style="display:none">
                                              <i class="icon-cash4 position-left"></i>
                                              Total a pagar
                                          </legend>

                                          <div class="form-group" style="display:none">
                                             <div class="row">
                                               <div id="div-txtRepues-I" class="col-sm-3">
                                                 <label>Repuestos <span class="text-danger">*</span></label>
                                                 <input type="text" id="txtRepues-I" name="txtRepues-I" placeholder="EJ. 1.50" class="form-control dinero SinNegativo" value="0">
                                               </div>

                                               <div id="div-txtManoObra-I" class="col-sm-3">
                                                 <label>Mano de Obra Por Hora <span class="text-danger">*</span></label>
                                                 <input type="text" id="txtManoObra-I" name="txtManoObra-I" placeholder="EJ. 1.50" class="form-control dinero SinNegativo" value="20">
                                               </div>
                                                
                                                <div id="div-txtHoraObra-I" class="col-sm-3">
                                                 <label>Cantidad de Horas<span class="text-danger">*</span></label>
                                                 <input type="text" id="txtHoraObra-I" name="txtHoraObra-I" placeholder="EJ. 1" class="form-control EnteroSinCero" value="1">
                                               </div>

                                               <div id="div-txtCosto-I" class="col-sm-3">
                                                   <label>Costo Reparacion <span class="text-danger dinero SinNegativo"> * </span></label>
                                                   <div class="input-group">
                                                   <span class="input-group-addon"><i class="icon-cash2"></i></span>
                                                   <input type="text" id="txtCosto-I" name="txtCosto-I" placeholder="0.00"
                                                    class="form-control dinero" disabled="disabled" readonly="true">
                                               </div>

                                             </div>
                                           </div>
                                        </div>
                                               
                                        <!-- campos de  -->
                                        <div class="form-group">
                                                
                                                
                                        </div>


                                          <div class="form-group" style="display:none">
                                             <div class="row">
                                               <div class="col-sm-4">
                                                 <label>Deposito Revision <span class="text-danger">*</span></label>
                                                 <input type="text" id="txtDRevi" name="txtDRevi" placeholder="EJ. 1.50"
                                                 class="touchspin-prefix" value="0" style="text-transform:uppercase;"
                                                  onkeyup="javascript:this.value=this.value.toUpperCase();">
                                               </div>

                                               <div class="col-sm-4">
                                                 <label>Deposito Reparacion <span class="text-danger">*</span></label>
                                                 <input type="text" id="txtDRepa" name="txtDRepa" placeholder="EJ. 1.50"
                                                 class="touchspin-prefix" value="0" style="text-transform:uppercase;"
                                                  onkeyup="javascript:this.value=this.value.toUpperCase();">
                                               </div>

                                               <div class="col-sm-4">
                                                   <label>PARCIAL A PAGAR<span class="text-danger"> * </span></label>
                                                   <div class="input-group">
                                                   <span class="input-group-addon"><i class="icon-cash"></i></span>
                                                   <input type="text" id="txtParcial" name="txtParcial" placeholder="0.00"
                                                    class="form-control" style="text-transform:uppercase;"
                                                   onkeyup="javascript:this.value=this.value.toUpperCase();"
                                                   readonly="readonly" disabled="disabled">
                                               </div>

                                             </div>
                                           </div>
                                         </div>


                                    </fieldset>
                                </div>
                              </div>
                              <!-- /basic tabs -->
                        </div>

      							<div class="modal-footer">
                      <button type="submit" id="btnSaveDatos" class="btn btn-primary">Guardar Datos
                        <i class="icon-file-upload position-right"></i></button>
    									<button  class="btn btn-default"
    									class="btn btn-link" data-dismiss="modal">Cerrar</button>
      							</div>
      						</form>
      					</div>
      				</div>
      			</div>
			    </div>
    </div>


      <!-- Iconified modal -->
        <div id="modal_iconified2" class="modal fade">
          <div class="modal-dialog modal-lg">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button"  id="btnclose" class="close" data-dismiss="modal">&times;</button>
                <h5 class="modal-title"><i class="icon-pencil7"></i> &nbsp; <span class="title-form"></span></h5>
              </div>
              <div class="modal-body" id="modal-container">
                <!-- Basic tabs -->
                  <div class="row">
                    <div class="col-md-12">
                      <div class="panel panel-flat">
                        <div class="panel-body">
                          <div class="alert alert-info alert-styled-left text-blue-800 content-group">
                                <span class="text-semibold">Estimado usuario</span>
                                Los campos remarcados con <span class="text-danger"> * </span> son necesarios.
                                <button type="button" class="close" data-dismiss="alert">×</button>
                           </div>
                                <form role="form" autocomplete="off" class="form-validate-jquery" id="frmDiagnostico">
                                  <input type="hidden" id="txtID_Di" name="txtID_Di" class="form-control">
                                  <fieldset>
                                    <legend class="text-semibold">
                                        <i class="icon-bell-plus position-left"></i>
                                        Estados
                                      </legend>

                                      <div class="form-group">
                                        <div class="row">
                                          <div class="col-sm-6">
                                            <label>Diagnostico <span class="text-danger">*</span></label>
                                             <textarea rows="3" class="form-control"
                                              placeholder="..." id="txtDiagnostico" name="txtDiagnostico"
                                              value="" style="text-transform:uppercase;"
                                              onkeyup="javascript:this.value=this.value.toUpperCase();">
                                              </textarea>
                                          </div>
                                          <div class="col-sm-6">
                                            <label>Estado <span class="text-danger">*</span></label>
                                             <textarea rows="3" class="form-control"
                                              placeholder="..." id="txtEstado" name="txtEstado"
                                              value="" style="text-transform:uppercase;"
                                              onkeyup="javascript:this.value=this.value.toUpperCase();">
                                              </textarea>
                                          </div>
                                        </div>
                                      </div>
									  
									  <div>
										<h3>Seleccione sus piezas</h3>
									</div>
									  
									  <!-- /basic tabs -->
									  <div class="form-group">
										<div class="row">
										  <div class="col-sm-4">
											<label>Pieza</label>
											<select  data-placeholder="Seleccione una marca..." id="cbProductosVigentes" name="cbProductosVigentes"
											  class="select-search" style="text-transform:uppercase;"
											  onkeyup="javascript:this.value=this.value.toUpperCase();">
											              <?php
															$filas = $objProducto->Listar_Productos_Vigentes();
															if (is_array($filas) || is_object($filas)) {
																foreach ($filas as $row => $column) {
																	?>
																	<option value="<?php print($column["idproducto"])?>"
																			data-price="<?php print($column["precio_venta"])?>"
																			data-stock="<?php print($column["stock"])?>">
																		<?php print($column["nombre_producto"])?>
																	</option>
																	<?php
																}
															}
															?>
											  </select>
										  </div>
										  
										<div class="col-sm-1">
										   <p>Precio: $<span id="price" class="dinero">0</span></p>
										</div>
										
										<div class="col-sm-1">
										   <p>Stock: $<span id="stock" >0</span></p>
										</div>
										
										<div class="col-sm-3">
										   <label for="quantity">Cantidad:</label>
										   <input type="number" class="form-control" id="quantity" min="1" />
										</div>
										
										<div class="col-sm-2"> 
											<label class="col-sm-12">&nbsp;</label>
											<button type="button"  id="BtnaddDiagnostico" class="btn btn-success">Añadir
											<i class="icon-arrow-right14 position-right"></i></button>
										 </div>
							  
										</div>
									</div>
									
									<div>
										<h3>Piezas seleccionadas</h3>
										<ul id="cart" class="cart"></ul>
									</div>
									
									</br>

                                    <legend class="text-semibold">
                                        <i class="icon-cash4 position-left"></i>
                                        Costo de Reparacion
                                    </legend>

                                    <div class="form-group">
                                       <div class="row">
                                         <div class="col-sm-3">
                                           <label>Repuestos <span class="text-danger">*</span></label>
											<input type="text" id="txtRepues" disabled="disabled" readonly="readonly" name="txtRepues" placeholder="0.00" class="form-control">
                                         </div>

                                         <div class="col-sm-3">
                                           <label>Mano de Obra <span class="text-danger">*</span></label>
                                           <input type="text" id="txtManoObra" name="txtManoObra" placeholder="EJ. 1.50"
                                           class="touchspin-prefix" value="0" style="text-transform:uppercase;"
                                            onkeyup="javascript:this.value=this.value.toUpperCase();">
                                         </div>
                                             
                                        <div id="div-txtHoraObra-D" class="col-sm-3">
                                                 <label>Cantidad de Horas<span class="text-danger">*</span></label>
                                                 <input type="text" id="txtHoraObra-D" name="txtHoraObra-D" placeholder="EJ. 1" class="form-control EnteroSinCero" value="1">
                                        </div>
                                         

                                         <div class="col-sm-3">
                                             <label>Costo Reparacion <span class="text-danger"> * </span></label>
                                             <div class="input-group">
                                             <span class="input-group-addon"><i class="icon-cash2"></i></span>
                                             <input type="text" id="txtCosto" name="txtCosto" placeholder="0.00"
                                              class="form-control" style="text-transform:uppercase;"
                                             onkeyup="javascript:this.value=this.value.toUpperCase();"
                                             readonly="readonly" disabled="disabled">
                                         </div>

                                       </div>
                                     </div>
                                  </div>

                                  <div class="form-group">
                                     <div class="row" style="display:none;">
                                       <div class="col-sm-4">
                                         <label>Deposito Para Revision</label>
                                         <input type="text" id="txtDRevi-D" name="txtDRevi-D" placeholder="EJ. 1.50"
                                         class="touchspin-prefix" value="0" style="text-transform:uppercase;"
                                          onkeyup="javascript:this.value=this.value.toUpperCase();">
                                       </div>

                                       <div class="col-sm-4">
                                         <label>Deposito Para Reparacion </label>
                                         <input type="text" id="txtDRepa-D" name="txtDRepa-D" placeholder="EJ. 1.50"
                                         class="touchspin-prefix" value="0" style="text-transform:uppercase;"
                                          onkeyup="javascript:this.value=this.value.toUpperCase();" >
                                       </div>

                                       <div class="col-sm-4">
                                           <label>PARCIAL A PAGAR </label>
                                           <div class="input-group">
                                           <span class="input-group-addon"><i class="icon-cash"></i></span>
                                           <input type="text" id="txtParcial-D" name="txtParcial-D" placeholder="0.00"
                                            class="form-control" style="text-transform:uppercase;"
                                           onkeyup="javascript:this.value=this.value.toUpperCase();"
                                           readonly="readonly" disabled="disabled">
                                       </div>

                                     </div>
                                   </div>
                                 </div>


                                     <legend class="text-semibold">
                                         <i class="icon-calendar position-left"></i>
                                         Fechas de Estado
                                     </legend>

                                     <div class="form-group">
                                        <div class="row">

                                          <div class="col-sm-3">
                                            <label>Fecha de Alta<span class="text-danger"> *</span></label>
                                            <div class="input-group">
                                            <span class="input-group-addon"><i class="icon-calendar3"></i></span>
                                            <input type="text" id="txtFechaA" name="txtFechaA" placeholder=""
                                             class="form-control" style="text-transform:uppercase;"
                                             onkeyup="javascript:this.value=this.value.toUpperCase();">
                                            </div>
                                          </div>

                                          <div class="col-sm-3">
                                            <label>Fecha de Retiro<span class="text-danger"> *</span></label>
                                            <div class="input-group">
                                            <span class="input-group-addon"><i class="icon-calendar3"></i></span>
                                            <input type="text" id="txtFechaR" name="txtFechaR" placeholder=""
                                             class="form-control" style="text-transform:uppercase;"
                                             onkeyup="javascript:this.value=this.value.toUpperCase();">
                                            </div>
                                          </div>

                                          <div class="col-sm-6">
                                            <label>Ubicacion</label><span class="text-danger"> *</span>
                                            <input type="text" id="txtUbicacion" name="txtUbicacion" placeholder="..."
                                             class="form-control" style="text-transform:uppercase;"
                                               onkeyup="javascript:this.value=this.value.toUpperCase();">
                                          </div>

                                        </div>
                                      </div>
                            </fieldset>
                        </div>
                      </div>
                    </div>
                  </div>
                  <!-- /basic tabs -->
              </div>

                  <div class="modal-footer">
                    <button type="submit"  id="btnSaveDiagnostico" class="btn btn-primary">Guardar Diagnostico
                      <i class="icon-arrow-right14 position-right"></i></button>
                    <button  type="reset" class="btn btn-default" id="reset"
                    class="btn btn-link" data-dismiss="modal">Cerrar</button>
                  </div>
              </form>
            </div>
          </div>
        </div>
      </div>

		</div>
	</div>
	<!-- /labels -->


    <!-- Large modal -->
  <div id="modal_ticket" class="modal fade">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">&times;</button>
          <h5 class="modal-title">Tickets de Orden</h5>
        </div>

        <div class="modal-body">
            <div class="row">
						<div class="col-md-12">
							<div class="panel panel-flat">
								<div class="panel-heading">
									<h6 class="panel-title">Ticket de Orden</h6>
								</div>
								<div class="panel-body">
                    <iframe name="ticket_frame" width="100%" height="450" id="ticket_frame" src="" frameborder="0" scrolling="yes"></iframe>
								</div>
							</div>
						</div>

						<div class="col-md-12">
							<div class="panel panel-flat">
								<div class="panel-heading">
									<h6 class="panel-title">Ticket de Auto</h6>
								</div>

								<div class="panel-body">

                  <iframe name="ticket2_frame"  width="100%" height="450"  id="ticket2_frame" src="" frameborder="0" scrolling="yes"></iframe>

								</div>
							</div>
						</div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-link" data-dismiss="modal">Cerrar</button>
        </div>
      </div>
    </div>
  </div>
  <!-- /large modal -->


  <?php } else { ?>

  	<div class="panel-body">
  		<div class="row">
  			<div class="col-md-12">

  				<!-- Widget with rounded icon -->
  				<div class="panel">
  					<div class="panel-body text-center">
  						<div class="icon-object border-danger-400 text-primary-400"><i class="icon-lock5 icon-3x text-danger-400"></i>
  						</div>
  						<h2 class="no-margin text-semibold"> SU USUARIO NO POSEE PERMISOS SUFICIENTES </h2>
  						<span class="text-uppercase text-size-mini text-muted">Su usuario no posee los permisos respectivos
  						para poder accesar a este modulo. Lo invitamos a dar click </span> <a href="./?View=Inicio">AQUI</a> <br><br>

  					</div>
  				</div>
  				<!-- /widget with rounded icon -->
  			</div>
  		</div>

  <?php } ?>
