<?php 

	spl_autoload_register(function($className){
		$model = "../../model/". $className ."_model.php";
		$controller = "../../controller/". $className ."_controller.php";
	
		require_once($model);
		require_once($controller);
	});

	$objProveedor =  new Proveedor();

 ?>
					<table class="table datatable-basic table-xxs table-hover">
						<thead>
							<tr>
								<th>No</th>
								<th>Proveedor</th>
								<th>RUC</th>
								<th>Telefono</th>
								<th>Estado</th>
								<th class="text-center">Opciones</th>
							</tr>
						</thead>

						<tbody>

						  <?php
								$filas = $objProveedor->Listar_Proveedores();
								if (is_array($filas) || is_object($filas))
								{
								foreach ($filas as $row => $column)
								{

							
								?>
									<tr>
					                	<td><?php print($column['codigo_proveedor']); ?></td>
					                	<td><?php print($column['nombre_proveedor']); ?></td>
					                	<td><?php print($column['numero_nrc']); ?></td>
					                	<td><?php print($column['numero_telefono']); ?></td>
					                	<td><?php if($column['estado'] == '1')
					                		echo '<span class="label label-success label-rounded"><span
					                		class="text-bold">VIGENTE</span></span>';
					                		else
					                		echo '<span class="label label-default label-rounded">
					                	<span
					                	    class="text-bold">DESCONTINUADO</span></span>'
						                ?></td>
					                	<td class="text-center">
										<ul class="icons-list">
											<li class="dropdown">
												<a href="#" class="dropdown-toggle" data-toggle="dropdown">
													<i class="icon-menu9"></i>
												</a>

												<ul class="dropdown-menu dropdown-menu-right">
													<li><a
													href="javascript:;" data-toggle="modal" data-target="#modal_iconified"
													onclick="openProveedor('editar',
								                     '<?php print($column["idproveedor"]); ?>',
								                     '<?php print($column["codigo_proveedor"]); ?>',
								                     '<?php print($column["nombre_proveedor"]); ?>',
								                     '<?php print($column["numero_telefono"]); ?>',
								                     '<?php print($column["numero_nit"]); ?>',
								                     '<?php print($column["numero_nrc"]); ?>',
								                     '<?php print($column["nombre_contacto"]); ?>',
								                     '<?php print($column["telefono_contacto"]); ?>',
								                     '<?php print($column["estado"]); ?>')">
												   <i class="icon-pencil6">
											       </i> Editar</a></li>
													<li><a
													href="javascript:;" data-toggle="modal" data-target="#modal_iconified"
													onclick="openProveedor('ver',
								                     '<?php print($column["idproveedor"]); ?>',
								                     '<?php print($column["codigo_proveedor"]); ?>',
								                     '<?php print($column["nombre_proveedor"]); ?>',
								                     '<?php print($column["numero_telefono"]); ?>',
								                     '<?php print($column["numero_nit"]); ?>',
								                     '<?php print($column["numero_nrc"]); ?>',
								                     '<?php print($column["nombre_contacto"]); ?>',
								                     '<?php print($column["telefono_contacto"]); ?>',
								                     '<?php print($column["estado"]); ?>')">
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
					</table>

<script type="text/javascript" src="web/custom-js/proveedor.js"></script>
