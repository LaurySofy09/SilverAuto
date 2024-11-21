<?php 
$objProducto =  new Producto();
$objVenta = new Venta();

?>


<div id="reload-div">
</div>


<div class="row">
 <div class="col-md-12 col-lg-12"> 
		<div class="panel panel-default">
			<div class="panel-heading">
				<h4 class="panel-title">Ver Histórico</h4>
			</div>
		</div>
 </div>
</div>


<div class="row">
	
<div class="panel-body">

	<div id="resultado">

		<div class="table-responsive">
		<table id="facturasTable" class="table table-xxs display">
			<thead>
				<tr class="bg-teal">
					<th>ID</th>
					<th class="text-center text-bold">Fecha de Venta</th>
					<th class="text-center text-bold">Número de Venta</th>
					<th class="text-center text-bold">Nombre de Cliente</th>
					<th class="text-center text-bold">Cantidad</th>
					<th class="text-center text-bold">Productos y precios</th>
					<th class="text-center text-bold">Precio</th>
					<th class="text-center text-bold">ITMBMS</th>
					<th class="text-center text-bold">Extento</th>
					<th class="text-center text-bold">Retenido</th>
					<th class="text-center text-bold">Descuento</th>
					<th class="text-center text-bold">Total</th>
					<td ><b><i class="icon-cash"></i></b></td>
				</tr>
			</thead>
			<tbody>
			</tbody>
		</table>
		</div>

</div>

</div>

</div>

<div id="modal_iconified_cash" class="modal fade"> 
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header"> 
			<button type="button" class="close" data-dismiss="modal">&times;</button>
			<h5 class="modal-title"><i class="icon-cash"></i> &nbsp; <span class="title-form">Detalle</span></h5>
			</div>
			<div class="modal-body" id="modal-container"> 
			
			</div>
		</div>
	</div>
</div>


<?php include('./includes/footer.inc.php'); ?>

</body>
</html>

<script type="text/javascript" src="web/custom-js/factura.js"></script>