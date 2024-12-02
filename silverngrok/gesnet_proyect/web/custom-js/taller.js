$('.cart').empty(); // Limpia el carrito
					localStorage.clear();
					sessionStorage.clear();       

	   var CampoMoneyParametrosLb = function (classCampo) {
            var campo = $("." + classCampo);
            campo.autoNumeric('init', { vMin: '-999999999999999.99', vMax: '999999999999999.99' });
         }

$(document).ready(function () {
     CampoMoneyParametrosLb("dinero");
	  $('.cart').empty();
	  localStorage.clear();
	  sessionStorage.clear();
	 $('#cbProductosVigentes').change(function() {
        var selectedOption = $(this).find('option:selected');
        var price = selectedOption.data('price');
        var stock = parseInt(selectedOption.data('stock')) - parseInt(getQuantityInCart(selectedOption.val()));
        // var stockOriginal = selectedOption.data('stock');
		// var cantidadCarrito = getQuantityInCart(selectedOption.val());
        $('#price').text(price);
        $('#stock').text(stock);
		$('#quantity').val('').attr('max', stock);
		SumarProductos(selectedOption);
    });
	
	$('#cbProductosVigentes').change();
	
	    // Añadir producto al carrito
	$(document).off('click', '#BtnaddDiagnostico').on('click', '#BtnaddDiagnostico', function() {
    //$('#BtnaddDiagnostico').click(function() {
        var productId = $('#cbProductosVigentes').val();
        var productName = $('#cbProductosVigentes option:selected').text();
        var price = $('#price').text();
        var quantity = $('#quantity').val();
        var stock = $('#stock').text();
        
        // Validar cantidad
        if (parseInt(quantity) > 0 && parseInt(quantity) <= parseInt(stock)) {
			
			if (isProductInCart(productId)) {
				swal({
                 title: "Lo sentimos...",
                 text: "Ya añadió esta pieza.",
                 confirmButtonColor: "#EF5350",
                 type: "error"
             });
			}
			else{
				$('.cart').append('<li data-id="' + productId + '" data-price="' + price + '" data-quantity="' + quantity + '">' + productName + ' - ' + quantity + ' unidades - $' + price + ' cada uno <button class="remove-item btn btn-danger" data-id="' + productId + '" data-price="' + price + '" data-quantity="' + quantity + '">Eliminar</button></li></br>');
				SumarProductos(productId);
				updateStock();
			}            
        } else {
            swal({
                 title: "Lo sentimos...",
                 text: "Ingrese una cantidad válida.",
                 confirmButtonColor: "#EF5350",
                 type: "error"
             });
        }
    });
	
	 // Eliminar producto del carrito
    $('.cart').on('click', '.remove-item', function() {
        var total = 0;
        var productId = parseInt($(this).data('id'));
        var price = parseFloat($(this).data('price'));
        var quantity = parseInt($(this).data('quantity'));
        var txtRepues = parseFloat($('#txtRepues').val());

        total = txtRepues - (price * quantity);
         $("#txtRepues").autoNumeric();
         $('#txtRepues').autoNumeric('set', parseFloat(total).toFixed(2));
         $('#txtRepues').change();

        $(this).closest('li').remove();
        updateStock();
    });
	
	$('#modal_iconified2').on('hidden.bs.modal', function () {
		location.reload(); // Recargar la página al cerrar el modal
	});

});


function EliminarDetalleOrdenClick(button){
swal({
			title: "¿Desea eliminar este detalle?",
			text: "Será eliminado permanentemente",
			showCancelButton: true,
			cancelButtonColor: "#EF5350",
			confirmButtonColor: "#43ABDB",
			confirmButtonText: "Si",
			cancelButtonText: "No",
			closeOnConfirm: false,
			closeOnCancel: false,
		}, function(isConfirm) {
			if (isConfirm) {
				var total = 0;
				// var productId = parseInt($(this).data('id'));
				// var price = parseFloat($(this).data('price'));
				// var quantity = parseInt($(this).data('quantity'));
				// var iddetalle= parseInt($(this).data('iddetalle'));
				var productId = parseInt($(button).data('id'));
				var price = parseFloat($(button).data('price'));
				var quantity = parseInt($(button).data('quantity'));
				var iddetalle= parseInt($(button).data('iddetalle'));
				var txtRepues = parseFloat($('#txtRepues').val());

				total = txtRepues - (price * quantity);
				 $("#txtRepues").autoNumeric();
				 $('#txtRepues').autoNumeric('set', parseFloat(total).toFixed(2));
				 $('#txtRepues').change();

				$(button).closest('li').remove();
				updateStock();
				EliminarDetalleOrden(iddetalle, productId, quantity);
			}else {
				swal.close();  // Cierra el Swal cuando se presiona "No"
			}
 
		});	

}

function EliminarDetalleOrden(idDetalle, idproducto ,Cantidad)
{
	 var urlprocess = 'web/ajax/ajxtaller.php';
	 
	 $.ajax({
		 type:'POST',
		    url:urlprocess,
		    data: 'proceso=deleteDetalle' + '&iddetalle=' + idDetalle + '&idproducto=' + idproducto + '&cantidad=' + Cantidad,
		    dataType: 'json',
			success: function(data){
				swal.close();
				console.log(data);				
			},
			error: function(xhr, status, error) {
				swal({
					 title: "Lo sentimos...",
					 text: "Hubo un error. Estatus. "+ error,
					 confirmButtonColor: "#EF5350",
					 type: "error"
					 });
			console.log('Error: ' + error);
			console.log('XHR: ' + JSON.stringify(xhr));
			console.log('Status: ' + status);
			}
		 
	 });
	
}

    function isProductInCart(productId) {
        var isInCart = false;
        $('.cart li').each(function() {
            if ($(this).data('id') == productId) {
                isInCart = true;
            }
        });
        return isInCart;
    }

	function getQuantityInCart(productId) {
        var totalQuantity = 0;
        $('.cart li').each(function() {
            if ($(this).data('id') == productId) {
                totalQuantity += parseInt($(this).data('quantity'));
            }
        });
        return totalQuantity;
    }
	
	function SumarProductos()
	{
		var total = 0;
		var txtRepues = parseFloat($('#txtRepues').val());
		var price = parseFloat($('#price').text());
        var quantity = parseFloat($('#quantity').val());
		
		total = txtRepues + (price * quantity);
		 $("#txtRepues").autoNumeric();
         $('#txtRepues').autoNumeric('set', parseFloat(total).toFixed(2));
		 $('#txtRepues').change();
	}

    function updateStock() {
        var selectedOption = $('#cbProductosVigentes').find('option:selected');
        var stock = selectedOption.data('stock') - getQuantityInCart(selectedOption.val());
        $('#stock').text(stock);
        $('#quantity').attr('max', stock); // Actualizar el max valor del campo de cantidad
    }

$(function() {

    $(document).on('click', '#print_ticket', function(e){
         var productId = $(this).data('id');
         Print_Report('Ticket',productId);
         e.preventDefault();
    });

    $(document).on('click', '#print_invoice', function(e){
         var productId = $(this).data('id');
         Print_Report('Orden',productId);
         e.preventDefault();
    });

    $(document).on('click', '#delete_product', function(e){

         var productId = $(this).data('id');
         SwalDelete(productId);
         e.preventDefault();
    });

  $('#btnEditar').hide();

    $('#txtF1').datetimepicker({
          locale: 'es',
          format: 'DD/MM/YYYY',
          useCurrent:true,
          viewDate: moment()

    });

    $('#txtF2').datetimepicker({
          locale: 'es',
          format: 'DD/MM/YYYY',
          useCurrent: false
    });

    $("#txtF1").on("dp.change", function (e) {
              $('#txtF2').data("DateTimePicker").minDate(e.date);
          });
    $("#txtF2").on("dp.change", function (e) {
      $('#txtF1').data("DateTimePicker").maxDate(e.date);
    });

    $('#txtFechaI').datetimepicker({
      locale: 'es',
      format: 'DD/MM/YYYY HH:mm:ss'

    });

    $('#txtFechaR').datetimepicker({
      locale: 'es',
      format: 'DD/MM/YYYY HH:mm:ss'

    });

    $('#txtFechaA').datetimepicker({
      locale: 'es',
      format: 'DD/MM/YYYY HH:mm:ss'

    });

    // Table setup
    // ------------------------------

    // Setting datatable defaults
    $.extend( $.fn.dataTable.defaults, {
        autoWidth: false,
        pageLength: 50,
        columnDefs: [{
            orderable: false,
            width: '100px'
        }],
        dom: '<"datatable-header"fpl><"datatable-scroll"t><"datatable-footer"ip>',
        language: {
            search: '<span>Buscar:</span> _INPUT_',
            lengthMenu: '<span>Ver:</span> _MENU_',
            emptyTable: "No existen registros",
            sZeroRecords:    "No se encontraron resultados",
            sInfoEmpty:      "No existen registros que contabilizar",
            sInfoFiltered:   "(filtrado de un total de _MAX_ registros)",
            sInfo:           "Mostrando del registro _START_ al _END_ de un total de _TOTAL_ datos",
            paginate: { 'first': 'First', 'last': 'Last', 'next': '&rarr;', 'previous': '&larr;' }

        },
        drawCallback: function () {
            $(this).find('tbody tr').slice(-3).find('.dropdown, .btn-group').addClass('dropup');
        },
        preDrawCallback: function() {
            $(this).find('tbody tr').slice(-3).find('.dropdown, .btn-group').removeClass('dropup');
        }
    });


    // Basic datatable
    $('.datatable-basic').DataTable();

    // Add placeholder to the datatable filter option
    $('.dataTables_filter input[type=search]').attr('placeholder','Escriba para filtrar...');


    // Enable Select2 select for the length option
    $('.dataTables_length select').select2({
        minimumResultsForSearch: Infinity,
        width: 'auto'
    });

        $('.select-search').select2();

    // Prefix
    $("#txtDRevi").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '$'
    });

    // Prefix
    $("#txtDRepa").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '$'
    });

    // Prefix
    $("#txtDRevi-D").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '$'
    });

    // Prefix
    $("#txtDRepa-D").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '$'
    });


    // Prefix
   /* $("#txtRepues").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '$'
    });*/

    // Prefix
    $("#txtManoObra").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '$'
    });

    // Prefix cambié aqui
   /* $("#txtRepues-I").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '$'
    });*/

    // Prefix
   /* $("#txtManoObra-I").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '$'
    });*/

    var validator = $("#frmInformacion").validate({

     ignore: '.select2-search__field', // ignore hidden fields
     errorClass: 'validation-error-label',
     successClass: 'validation-valid-label',

     highlight: function(element, errorClass) {
         $(element).removeClass(errorClass);
     },
     unhighlight: function(element, errorClass) {
         $(element).removeClass(errorClass);
     },
     // Different components require proper error label placement
     errorPlacement: function(error, element) {

       // Input with icons and Select2
        if (element.parents('div').hasClass('has-feedback') || element.hasClass('select2-hidden-accessible')) {
             error.appendTo( element.parent() );
         }

        // Input group, styled file input
         else if (element.parent().hasClass('uploader') || element.parents().hasClass('input-group')) {
             error.appendTo( element.parent().parent() );
         }

       else {
           error.insertAfter(element);
       }

     },

     rules: {
       txtNoOrden:{
         maxlength:175,
         required: true
       },
      /* txtFechaI:{
         required: true
       },*/
       cbCliente:{
         required: true
       },
       /*txtAparato:{
          maxlength:125,
         required: true
       },*/
       txtModelo:{
        maxlength:125,
        required:true
       },
       cbMarca:{
         required: true
       },
       /*txtSerie:{
         maxlength:125
       },*/
       cbTecnico:{
         required: true
       },
       txtAveria:{
         maxlength:200,
         required: true
       },
       txtObservaciones:{
         maxlength:200,
         required: true
       }
       /*txtDRevi:{
         required: true
       },
       txtDRepa:{
         required: true
       },
       txtParcial:{
         required:true
       }*/
     },
   validClass: "validation-valid-label",
    success: function(label) {
         label.addClass("validation-valid-label").text("Correcto.")
     },

      submitHandler: function (form) {
          enviar_informacion();
       }
    });

    var validator = $("#frmDiagnostico").validate({

     ignore: '.select2-search__field', // ignore hidden fields
     errorClass: 'validation-error-label',
     successClass: 'validation-valid-label',

     highlight: function(element, errorClass) {
         $(element).removeClass(errorClass);
     },
     unhighlight: function(element, errorClass) {
         $(element).removeClass(errorClass);
     },
     // Different components require proper error label placement
     errorPlacement: function(error, element) {

       // Input with icons and Select2
        if (element.parents('div').hasClass('has-feedback') || element.hasClass('select2-hidden-accessible')) {
             error.appendTo( element.parent() );
         }

        // Input group, styled file input
         else if (element.parent().hasClass('uploader') || element.parents().hasClass('input-group')) {
             error.appendTo( element.parent().parent() );
         }

       else {
           error.insertAfter(element);
       }

     },

     rules: {
       txtDiagnostico:{
         maxlength:200,
         required: true
       },
       txtEstado:{
         maxlength:200,
         required:true
       },
       txtRepues:{
         required:true
       },
       txtManoObra:{
         required:true
       },
       txtFechaA:{
         required:true
       },
       txtUbicacion:{
         required:true
       },
       txtParcial:{
         required:true
       }
     },
   validClass: "validation-valid-label",
    success: function(label) {
         label.addClass("validation-valid-label").text("Correcto.")
     },

      submitHandler: function (form) {
          enviar_diagnostico();
       }
    });

      var form = $('#frmInformacion');

      $('#cbCliente', form).change(function () {
           form.validate().element($(this)); //revalidate the chosen dropdown value and show error or success message for the input
       });

      $('#cbMarca', form).change(function () {
           form.validate().element($(this)); //revalidate the chosen dropdown value and show error or success message for the input
       });

       $('#cbTecnico', form).change(function () {
            form.validate().element($(this)); //revalidate the chosen dropdown value and show error or success message for the input
        });


        var validator = $("#frmSearch").validate({

         ignore: '.select2-search__field', // ignore hidden fields
         errorClass: 'validation-error-label',
         successClass: 'validation-valid-label',

         highlight: function(element, errorClass) {
             $(element).removeClass(errorClass);
         },
         unhighlight: function(element, errorClass) {
             $(element).removeClass(errorClass);
         },
         // Different components require proper error label placement
         errorPlacement: function(error, element) {

           // Input with icons and Select2
            if (element.parents('div').hasClass('has-feedback') || element.hasClass('select2-hidden-accessible')) {
                 error.appendTo( element.parent() );
             }

            // Input group, styled file input
             else if (element.parent().hasClass('uploader') || element.parents().hasClass('input-group')) {
                 error.appendTo( element.parent().parent() );
             }

           else {
               error.insertAfter(element);
           }

         },

         rules: {
           txtF1:{
             required: true
           },
           txtF2:{
             required:true
           }
         },
       validClass: "validation-valid-label",
        success: function(label) {
             label.addClass("validation-valid-label").text("Correcto.")
         },

          submitHandler: function (form) {
              buscar_datos();
           }
        });

});


function limpiarform1(){

  var form = $( "#frmInformacion" ).validate();
  form.resetForm();

}

function limpiarform2(){

  var form = $( "#frmDiagnostico" ).validate();
  form.resetForm();

}

function Costo_Reparacion(){

var parametro = $("#txtProceso_I").val();

 if(parametro == 'Informacion'){

   var repuestos = $("#txtRepues").val();
   var mano_obra = $("#txtManoObra").val();
   var horaObra =  parseInt($('#txtHoraObra-D').val()) || 1;

   var costo_reparacion = 0;
   if(repuestos =='' && mano_obra==''){
     repuestos = 0.00;
     mano_obra - 0.00;
     costo_reparacion = 0.00;
   } else if (repuestos !='' && mano_obra ==''){
     costo_reparacion = parseFloat(repuestos);
   } else if (repuestos == '' && mano_obra !=''){
     costo_reparacion = parseFloat(mano_obra) * horaObra;
   } else if (repuestos != '' && mano_obra!=''){
     costo_reparacion = parseFloat(repuestos) + (parseFloat(mano_obra) * horaObra);
   }

   var deposito_revision = $("#txtDRevi").val();
   var deposito_reparacion = $("#txtDRepa").val();
   var parcial = 0;

   if(deposito_revision == ''){deposito_revision = 0.00};
   if(deposito_reparacion == ''){deposito_reparacion = 0.00};

   $("#txtCosto").val(costo_reparacion.toFixed(2));
   parcial =  costo_reparacion - (parseFloat(deposito_revision) + parseFloat(deposito_reparacion));

   $("#txtParcial").val(parcial.toFixed(2));

 } else if (parametro == 'Editar-Informacion'){

   var repuestos = $("#txtRepues-I").val();
   var mano_obra = $("#txtManoObra-I").val();
   var horaObra =  parseInt($('#txtHoraObra-D').val()) || 1;
   var costo_reparacion = 0;
   if(repuestos =='' && mano_obra==''){
     repuestos = 0.00;
     mano_obra - 0.00;
     costo_reparacion = 0.00;
   } else if (repuestos !='' && mano_obra ==''){
     costo_reparacion = parseFloat(repuestos);
   } else if (repuestos == '' && mano_obra !=''){
     costo_reparacion = parseFloat(mano_obra) * horaObra;
   } else if (repuestos != '' && mano_obra!=''){
     costo_reparacion = parseFloat(repuestos) + (parseFloat(mano_obra) * horaObra);
   }

   var deposito_revision = $("#txtDRevi").val();
   var deposito_reparacion = $("#txtDRepa").val();
   var parcial = 0;

   if(deposito_revision == ''){deposito_revision = 0.00};
   if(deposito_reparacion == ''){deposito_reparacion = 0.00};

   $("#txtCosto").val(costo_reparacion.toFixed(2));
   parcial =  costo_reparacion - (parseFloat(deposito_revision) + parseFloat(deposito_reparacion));

   $("#txtParcial").val(parcial.toFixed(2));


 } else if(parametro == ''){

   var repuestos = $("#txtRepues").val();
   var mano_obra = $("#txtManoObra").val();
   var horaObra =  parseInt($('#txtHoraObra-D').val()) || 1;
   
   var costo_reparacion = 0;
   if(repuestos =='' && mano_obra==''){
     repuestos = 0.00;
     mano_obra - 0.00;
     costo_reparacion = 0.00;
   } else if (repuestos !='' && mano_obra ==''){
     costo_reparacion = parseFloat(repuestos);
   } else if (repuestos == '' && mano_obra !=''){
     costo_reparacion = parseFloat(mano_obra) * horaObra;
   } else if (repuestos != '' && mano_obra!=''){
     costo_reparacion = parseFloat(repuestos) + (parseFloat(mano_obra) * horaObra);
   }

   var deposito_revision = $("#txtDRevi-D").val();
   var deposito_reparacion = $("#txtDRepa-D").val();
   var parcial = 0;

   if(deposito_revision == ''){deposito_revision = 0.00};
   if(deposito_reparacion == ''){deposito_reparacion = 0.00};

   $("#txtCosto").val(costo_reparacion.toFixed(2));
   parcial =  costo_reparacion - (parseFloat(deposito_revision) + parseFloat(deposito_reparacion));

   $("#txtParcial-D").val(parcial.toFixed(2));

 }



}

/*function Ver_Max(){
  $.ajax({
        type:'GET',
        url: 'web/ajax/ajxtaller.php?criterio=max',
        success: function (data){
          var valor = $.parseJSON(data)
          $("#txtNoOrden").val(valor);
          //console.log(data);
        }
    });
}*/

function newOrden()
 {
    //Ver_Max();       
	$('.cart').empty();
	localStorage.clear();
    sessionStorage.clear();
    openOrden('nuevo',null,null,null,null,null,null,null,null,null);
    $('#modal_iconified').modal('show');
 }
function openOrden(action, 
idorden,
 numero_orden, 
 fecha_ingreso, 
 idcliente, 
 Placa, 
 AnioAuto, 
 modelo, 
 idmarca, 
 serie, 
 idtecnico, 
 averia, 
 observaciones, 
 deposito_revision, 
 deposito_reparacion, 
 diagnostico, 
 estado_aparato, 
 repuestos, 
 mano_obra, 
 fecha_alta, 
 fecha_retiro, 
 ubicacion, 
 parcial_pagar, 
 montoRepuesto, 
 ManoObra, 
 horaObra)
{

  $("#txtRepues").change(function(){
      Costo_Reparacion();
  });

  $("#txtManoObra").change(function(){
      Costo_Reparacion();
  });

  $("#txtDRepa").change(function(){
    Costo_Reparacion();
  });

  $("#txtDRevi").change(function(){
    Costo_Reparacion();
  });

   if (action == 'diagnostico' || action == 'diagnostico-editar'){
       $('#modal_iconified2').on('shown.bs.modal', function () {

        var modal = $(this);
		$('.cart').empty();
		localStorage.clear();
        sessionStorage.clear();
		$('#quantity').val('');
        if (action == 'diagnostico'){
           
           $('#txtProceso_I').val('');

           $('#txtID_I').val('');
           $('#txtProceso_I').val('');
           $('#txtID_Di').val(idorden);
           $('#txtDiagnostico').val('');
           $('#txtEstado').val('');
           $('#txtRepues').val('');
           $('#txtFechaA').val('');
           $('#txtFechaR').val('');
           $('#txtManoObra').val('');
           $('#txtCosto').val('');
           $('#txtParcial-D').val('');
           $('#txtUbicacion').val('');

           $('#txtDRevi-D').val(deposito_revision);
           $('#txtDRepa-D').val(deposito_reparacion);
           $('#txtParcial-D').val(parcial_pagar);

           $('#txtDiagnostico').prop( "disabled" , false);
           $('#txtEstado').prop( "disabled" , false);
           $('#txtFechaR').prop( "disabled" , false);
           $('#txtFechaA').prop( "disabled" , false);
           $('#txtRepues').prop( "disabled" , false);
           $('#txtManoObra').prop( "disabled" , false);
           $('#txtCosto').prop( "disabled" , true);
           $('#txtUbicacion').prop( "disabled" , false);
            
            $('#txtDRevi-D').prop( "disabled" , false);
            $('#txtDRepa-D').prop( "disabled" , false);
            $('#txtParcial-D').prop( "disabled" , false);
             limpiarform2();
            
            
           
            
         var valorRepuesto = montoRepuesto || "0";
         var RepuestoNum = parseFloat((Number((valorRepuesto.replace(/[^0-9.-]+/g, ""))).toFixed(2)));
         var valorManoObra= ManoObra || "0";
         var ManoObraNum = parseFloat((Number((valorManoObra.replace(/[^0-9.-]+/g, ""))).toFixed(2)));
         var Horas = parseInt(horaObra) || 1;

         var costo = RepuestoNum + (ManoObraNum * Horas);
         
         $("#txtRepues").autoNumeric();
         $('#txtRepues').autoNumeric('set', parseFloat(RepuestoNum).toFixed(2));
         
         $("#txtManoObra").autoNumeric();
         $('#txtManoObra').autoNumeric('set', parseFloat(ManoObraNum).toFixed(2));
         
         $('#txtHoraObra-D').val(horaObra)
         
         $("#txtCosto").autoNumeric();
         $('#txtCosto').autoNumeric('set', parseFloat(costo).toFixed(2));
            
         $('#txtRepues').change(function(){
         calcularCosto_D();
        });


      $('#txtManoObra').change(function(){
       calcularCosto_D();
       });

      $('#txtHoraObra-D').change(function(){
        calcularCosto_D();
       });


        calcularCosto_D();
            
         function calcularCosto_D()
        {

         var valorRepuesto = $('#txtRepues').val() || "0";
         var RepuestoNum = parseFloat((Number((valorRepuesto.replace(/[^0-9.-]+/g, ""))).toFixed(2)));
         var valorManoObra= $('#txtManoObra').val() || "0";
         var ManoObraNum = parseFloat((Number((valorManoObra.replace(/[^0-9.-]+/g, ""))).toFixed(2)));
         var Horas = parseInt($('#txtHoraObra-D').val()) || 1;

         var costo = RepuestoNum + (ManoObraNum * Horas);
         $("#txtCosto").autoNumeric();
         $('#txtCosto').autoNumeric('set', parseFloat(costo).toFixed(2));
        }
                  
        modal.find('.title-form').text('Ingresar Diagnostico de Aparato');
           

         } else if (action == 'diagnostico-editar'){

             
            //EDITAR
           //  $('#modal_iconified').modal('show');
		   /// datos desordenados
             $('#txtID_Di').val(idorden);
             $('#txtID_I').val('');
             $('#txtProceso_I').val('');

             $('#txtFechaA').val(fecha_alta);  //  mano_obra
             $('#txtFechaR').val(fecha_retiro); // fecha_alta
             $('#txtDiagnostico').val(diagnostico); // deposito_reparacion
             $('#txtEstado').val(estado_aparato); // diagnostico
             $('#txtAnio').val(AnioAuto); // AnioAuto
             $('#txtPlaca').val(Placa); // Placa
             $('#txtEstado').val(estado_aparato); // diagnostico
             $('#txtRepues').val(repuestos); // estado_aparato
             $('#txtManoObra').val(mano_obra); //repuestos
		     $('#txtUbicacion').val(ubicacion); // fecha_retiro
		     $('#txtHoraObra-D').val(horaObra);
         // var valorRepuesto = montoRepuesto || "0";
         // var RepuestoNum = parseFloat((Number((valorRepuesto.replace(/[^0-9.-]+/g, ""))).toFixed(2)));
         // var valorManoObra= ManoObra || "0";
         // var ManoObraNum = parseFloat((Number((valorManoObra.replace(/[^0-9.-]+/g, ""))).toFixed(2)));
         // var Horas = parseInt(horaObra) || 1;

         // var costo = RepuestoNum + (ManoObraNum * Horas);
         
         // $("#txtRepues-I").autoNumeric();
         // $('#txtRepues-I').autoNumeric('set', parseFloat(RepuestoNum).toFixed(2));
		 
		  // $("#txtRepues").autoNumeric();
         // $('#txtRepues').autoNumeric('set', parseFloat(RepuestoNum).toFixed(2));
         
         // $("#txtManoObra-I").autoNumeric();
         // $('#txtManoObra-I').autoNumeric('set', parseFloat(ManoObraNum).toFixed(2));
         
		 // $("#txtManoObra").autoNumeric();
         // $('#txtManoObra').autoNumeric('set', parseFloat(ManoObraNum).toFixed(2));	 
		 
         // $('#txtHoraObra-I').val(horaObra)
		 // $('#txtHoraObra-D').val(horaObra)
         
         // $("#txtCosto-I").autoNumeric();
         // $('#txtCosto-I').autoNumeric('set', parseFloat(costo).toFixed(2));
		 
		 // $("#txtCosto").autoNumeric();
         // $('#txtCosto').autoNumeric('set', parseFloat(costo).toFixed(2));
		 
        var urlprocess = 'web/ajax/ajxtaller.php';
		console.log(idorden);
		//aqui va la consulta ajax 
		$.ajax({
			type:'POST',
		    url:urlprocess,
		    data: 'proceso=detalleOrden'+ '&idorden=' + idorden,
		    dataType: 'json',
			success: function(data){
				$('.cart').empty();
				localStorage.clear();
                sessionStorage.clear();
				console.log(data);
				if (Array.isArray(data)) {
					data.forEach(function(item) {
					//$('.cart').append(`<li data-id="${item.idproducto}" data-price="${item.precio}" data-quantity="${item.cantidad}"> ${item.nombre_producto} - ${item.cantidad} x $${item.precio} cada uno. <button type="button" onclick="EliminarDetalleOrdenClick()" class="remove-from-cart btn btn-danger" data-iddetalle="${item.idDetalle}" data-quantity="${item.cantidad}" data-price=${item.precio} data-id="${item.idproducto}">Eliminar</button></li></br>`);
					 $('.cart').append(`<li data-id="${item.idproducto}" data-price="${item.precio}" data-quantity="${item.cantidad}"> ${item.nombre_producto} - ${item.cantidad} x $${item.precio} cada uno. <button type="button" onclick="EliminarDetalleOrdenClick(this)" class="remove-from-cart btn btn-danger" data-iddetalle="${item.idDetalle}" data-quantity="${item.cantidad}" data-price="${item.precio}" data-id="${item.idproducto}">Eliminar</button></li></br>`);
					});
				}
				else{
					console.log('El dato recibido no es un array: ', data);
				}
            				
			},
			error: function(xhr, status, error) {
				swal({
					 title: "Lo sentimos...",
					 text: "Hubo un error. Estatus. "+ error,
					 confirmButtonColor: "#EF5350",
					 type: "error"
					 });
			console.log('Error: ' + error);
			console.log('XHR: ' + JSON.stringify(xhr));
			console.log('Status: ' + status);
			}
			
		});
         
		 Costo_Reparacion();
		 modal.find('.title-form').text('Editar Diagnostico de Aparato');
         }

   });
}
    
   

    $('#modal_iconified').on('shown.bs.modal', function () {
     var modal = $(this);  
        
     // campos sólo números enteros sin ceros
     $('.EnteroSinCero').keyup(function () {
        if (this.value != this.value.replace(/[^0-9]/g, '')) {
            this.value = this.value.replace(/[^0-9]/g, '');
        }

        if (this.value != this.value.replace(/^(0+)/g, '')) {
            this.value = this.value.replace(/^(0+)/g, '');
        }
    });
         
    $('.SinNegativo').keyup(function () {
        if (this.value != this.value.replace(/^(-+)/g, '')) {
            this.value = this.value.replace(/^(-+)/g, '');
        }
	$('#txtRepues').prop( "disabled" , true);
    });
         
         
     $('#txtRepues-I').change(function(){
         calcularCosto();
     });


      $('#txtManoObra-I').change(function(){
       calcularCosto();
     });

      $('#txtHoraObra-I').change(function(){
        calcularCosto();
     });




     calcularCosto();

     function calcularCosto()
     {

         var valorRepuesto = $('#txtRepues-I').val() || "0";
         var RepuestoNum = parseFloat((Number((valorRepuesto.replace(/[^0-9.-]+/g, ""))).toFixed(2)));
         var valorManoObra= $('#txtManoObra-I').val() || "0";
         var ManoObraNum = parseFloat((Number((valorManoObra.replace(/[^0-9.-]+/g, ""))).toFixed(2)));
         var Horas = parseInt($('#txtHoraObra-I').val()) || 1;

         var costo = RepuestoNum + (ManoObraNum * Horas);
         $("#txtCosto-I").autoNumeric();
         $('#txtCosto-I').autoNumeric('set', parseFloat(costo).toFixed(2));
		 
		 $("#txtCosto").autoNumeric();
         $('#txtCosto').autoNumeric('set', parseFloat(costo).toFixed(2));
     }
        
     if (action == 'nuevo'){

       $('#txtID_Di').val('');
       $('#txtID_I').val('');

       $('#txtProceso_I').val('Informacion');

       $('#txtNoOrden').val('');
       $('#txtFechaI').val('');
       $('#txtFechaA').val('');
       $('#txtFechaR').val('');
       $('#txtAparato').val('');
       $('#txtModelo').val('');
       $('#txtSerie').val('');
       $('#txtAveria').val('');
       $('#txtObservaciones').val('');
       $('#txtDiagnostico').val('');
       $('#txtEstado').val('');
       $('#txtDRevi').val('');
       $('#txtDRepa').val('');
       $('#txtRepues').val('');
       $('#txtManoObra').val('');
       $('#txtCosto').val('');

       $('#txtRepues-I').val('');
       $('#txtManoObra-I').val('20'); //-- Cambie aqui
       $('#txtCosto-I').val('0');  // -- Cambie aqui
       $('#txtHoraObra-I').val('1');

       $('#txtParcial').val('');
       $('#txtUbicacion').val('');
       $("#cbCliente").select2("val", "All");
       $("#cbMarca").select2("val", "All");
       $("#cbTecnico").select2("val", "All");

       $('#txtNoOrden').prop( "disabled" , true);
       $('#txtFechaI').prop( "disabled" , true);
       $('#txtFechaA').prop( "disabled" , true);
       $('#txtFechaR').prop( "disabled" , true);
       $('#txtAparato').prop( "disabled" , false);
       $('#txtModelo').prop( "disabled" , false);
       $('#txtSerie').prop( "disabled" , false);
       $('#txtAveria').prop( "disabled" , false);
       $('#txtObservaciones').prop( "disabled" , false);
       $('#txtDiagnostico').prop( "disabled" , true);
       $('#txtEstado').prop( "disabled" , true);
       $('#txtDRevi').prop( "disabled" , false);
       $('#txtDRepa').prop( "disabled" , false);
       $('#txtRepues').prop( "disabled" , true);
       $('#txtManoObra').prop( "disabled" , true);
       $('#txtCosto').prop( "disabled" , true);
       $('#txtParcial').prop( "disabled" , true);
       $('#txtUbicacion').prop( "disabled" , true);
       $('#cbCliente').prop( "disabled" , false);
       $('#cbMarca').prop( "disabled" , false);
       $('#cbTecnico').prop( "disabled" , false);
       //$("#div-txtRepues-I").hide();  -- Cambie aqui
       //$("#div-txtCosto-I").hide();  -- Cambie aqui
      // $("#div-txtManoObra-I").hide(); -- Cambie aqui

    
         
         
      limpiarform1();


      modal.find('.title-form').text('Ingresar Orden de Taller');

     } else if(action=='informacion-editar') {

    //  $('#modal_iconified').modal('show');
      $('#txtID_Di').val('');
      $('#txtID_I').val(idorden);

      $('#txtProceso_Di').val('');
      $('#txtProceso_I').val('Editar-Informacion');

      $('#txtNoOrden').val(numero_orden);
      $('#txtFechaI').val(fecha_ingreso);
      $('#txtAparato').val("");
      $('#txtModelo').val(modelo);
      $('#txtSerie').val(serie);
      $('#txtAveria').val(averia);
      $('#txtObservaciones').val(observaciones);
      $('#txtDRevi').val(deposito_revision);
      $('#txtDRepa').val(deposito_reparacion);
      $('#txtParcial').val(parcial_pagar);

        var valorRepuesto = montoRepuesto || "0";
         var RepuestoNum = parseFloat((Number((valorRepuesto.replace(/[^0-9.-]+/g, ""))).toFixed(2)));
         var valorManoObra= ManoObra || "0";
         var ManoObraNum = parseFloat((Number((valorManoObra.replace(/[^0-9.-]+/g, ""))).toFixed(2)));
         var Horas = parseInt(horaObra) || 1;

         var costo = RepuestoNum + (ManoObraNum * Horas);
         
         $("#txtRepues-I").autoNumeric();
         $('#txtRepues-I').autoNumeric('set', parseFloat(RepuestoNum).toFixed(2));
         
         $("#txtManoObra-I").autoNumeric();
         $('#txtManoObra-I').autoNumeric('set', parseFloat(ManoObraNum).toFixed(2));
         
         $('#txtHoraObra-I').val(horaObra)
         
         $("#txtCosto-I").autoNumeric();
         $('#txtCosto-I').autoNumeric('set', parseFloat(costo).toFixed(2));
         
      $('#txtAnio').val(AnioAuto);
      $('#txtPlaca').val(Placa);
      $("#cbCliente").val(idcliente).trigger("change");
      $("#cbMarca").val(idmarca).trigger("change");
      $("#cbTecnico").val(idtecnico).trigger("change");


      $('#txtNoOrden').prop( "disabled" , true);
      //$('#txtFechaI').prop( "disabled" , false);
      //$('#txtAparato').prop( "disabled" , false);
      $('#txtModelo').prop( "disabled" , false);
      $('#txtSerie').prop( "disabled" , false);
      $('#txtAveria').prop( "disabled" , false);
      $('#txtObservaciones').prop( "disabled" , false);
      $('#txtDRevi').prop( "disabled" , false);
      $('#txtDRepa').prop( "disabled" , false);
      $('#txtParcial').prop( "disabled" , true);
      $('#cbCliente').prop( "disabled" , false);
      $('#cbMarca').prop( "disabled" , false);
      $('#cbTecnico').prop( "disabled" , false);
      $("#div-txtRepues-I").show();
      $("#div-txtCosto-I").show();
      $("#div-txtManoObra-I").show();
      Costo_Reparacion();
      modal.find('.title-form').text('Editar Orden de Taller');
    }
    

  });

}

function buscar_datos()
{
  var fecha1 = $("#txtF1").val();
  var fecha2 = $("#txtF2").val();

    if(fecha1!="" && fecha2!="")
    {
        $.ajax({

           type:"GET",
           url:"web/ajax/reload-taller.php?fecha1="+fecha1+"&fecha2="+fecha2,
           success: function(data){
              $('#reload-div').html(data);
           }

       });
    } else {

      $.ajax({

           type:"GET",
           url:"web/ajax/reload-taller.php?fecha1=empty&fecha2=empty",
           success: function(data){
              $('#reload-div').html(data);
           }

       });

    }

}

function enviar_informacion(){
    
    var fechaActual = new Date();

    // Obtener el año, mes y día
    var año = fechaActual.getFullYear();
    var mes = fechaActual.getMonth() + 1; // Meses en JavaScript se cuentan desde 0 (enero) hasta 11 (diciembre)
    var dia = fechaActual.getDate();

    // Formatear la fecha como una cadena (por ejemplo, "YYYY-MM-DD")
   var fechaFormateada = (dia < 10 ? '0' : '') + dia + '/' + (mes < 10 ? '0' : '') + mes + '/' + año;
    
    
  var urlprocess = 'web/ajax/ajxtaller.php';
  var id =  $("#txtID_I").val();
  var proceso = $('#txtProceso_I').val();
  var numero_orden  =$("#txtNoOrden").val();
 // var fecha_ingreso = null;
  var cliente  =$("#cbCliente").val();
  var tecnico = $("#cbTecnico").val();
  var aparato = "";
  var marca  =$("#cbMarca").val();
  var modelo  =$("#txtModelo").val();
  var serie  =$("#txtPlaca").val(); // cambie aqui
  var averia  =$("#txtAveria").val();
  var observaciones  =$("#txtObservaciones").val();
  var deposito_revision  =$("#txtDRevi").val();
  var deposito_reparacion  =$("#txtDRepa").val();
  var parcial  =$("#txtParcial").val();
  var repuesto =0; //$("#txtRepues-I").val(); en la fase 2, se cambió a esto. porque en este flujo no se sabe aun cuanto se va a cobrar. 
  var manoObra =0; //$("#txtManoObra-I").val();
  var hobraObra =0; //$("#txtHoraObra-I").val();
  var anioAuto =$("#txtAnio").val();  
 // var cedula =$("#txtCedula").val();
    
  var dataString='proceso='+proceso+'&id='+id+'&cliente='+cliente+'&tecnico='+tecnico+'&aparato='+aparato+'&marca='+marca;
  dataString+='&modelo='+modelo+'&serie='+serie+'&averia='+averia+'&observaciones='+observaciones+'&numero_orden='+numero_orden;
  dataString+='&deposito_revision='+deposito_revision+'&deposito_reparacion='+deposito_reparacion+'&parcial='+parcial;
  dataString+='&Repuesto='+repuesto+'&ManoObra='+manoObra+'&HoraObra='+hobraObra +'&AnioAuto='+anioAuto;

  $.ajax({
     type:'POST',
     url:urlprocess,
     data: dataString,
     dataType: 'json',
     success: function(data){

       if(proceso == 'Informacion'){

         if(data=="Validado"){

           /*swal({
               title: "Exito!",
               text: "Orden Registrada Exitosamente!",
               confirmButtonColor: "#66BB6A",
               type: "success"
           });*/
			
			swal({
				title: "¡Éxito!",
				text: "Orden Registrada Exitosamente!",
				icon: "success",
				confirmButtonColor: "#43ABDB",
				confirmButtonText: "Ok",
				closeOnConfirm: true
			}, function(isConfirm) {
				if (isConfirm) {
					$('.cart').empty(); // Limpia el carrito
					localStorage.clear();
					sessionStorage.clear();
					$('#modal_iconified').modal('toggle');
					limpiarform1();
					location.reload(); // Recarga la página
				}
			});

			
           //$('#modal_iconified').modal('toggle');
           ///cargarDiv("#reload-div","web/ajax/reload-taller.php?fecha1=empty&fecha2=empty");
           //limpiarform1();

         } else if (data=="Duplicado"){

            swal({
                   title: "Ops!",
                   text: "El dato que ingresaste ya existe",
                   confirmButtonColor: "#EF5350",
                   type: "warning"
            });


         } else if(data =="Error"){

                swal({
                 title: "Lo sentimos...",
                 text: "No procesamos bien tus datos!",
                 confirmButtonColor: "#EF5350",
                 type: "error"
             });
         }


       } else  if(proceso == 'Editar-Informacion'){

         if(data=="Validado"){
          /* swal({
               title: "Exito!",
               text: "Orden Editada Exitosamente!",
               confirmButtonColor: "#2196F3",
              type: "info"
           });*/
          //Print_Ticket_Edit(id);	
			swal({
				title: "¡Éxito!",
				text: "Orden Editada Exitosamente!",
				icon: "success",
				confirmButtonColor: "#43ABDB",
				confirmButtonText: "Ok",
				closeOnConfirm: true
			}, function(isConfirm) {
				if (isConfirm) {
					$('.cart').empty(); // Limpia el carrito
					localStorage.clear();
                    sessionStorage.clear();
					$('#modal_iconified').modal('toggle');
					limpiarform1();
					limpiarform();
					location.reload(); // Recarga la página		
				}
			});
          
			
          // cargarDiv("#reload-div","web/ajax/reload-taller.php?fecha1=empty&fecha2=empty");  -------codigo original me da problemas con el cart 


         }  else if(data =="Error"){

                swal({
                 title: "Lo sentimos...",
                 text: "No procesamos bien tus datos!",
                 confirmButtonColor: "#EF5350",
                 type: "error"
             });
         }


       }


     },error: function(data) {

         console.log(data);
         
         swal({
            title: "Lo sentimos...",
            text: "Algo sucedio mal!",
            confirmButtonColor: "#EF5350",
            type: "error"
        });


     }

  });

}

function enviar_diagnostico(){
  var urlprocess = 'web/ajax/ajxtaller.php';
  var proceso = 'Diagnostico';
  var id =  $("#txtID_Di").val();
  var fecha_alta  =$("#txtFechaA").val();
  var fecha_retiro =$("#txtFechaR").val();
  var diagnostico  = $("#txtDiagnostico").val();
  var estado  =$("#txtEstado").val();
  var repuestos  =$("#txtRepues").val();
  var mano_obra  =$("#txtManoObra").val();
  var txtHoraObra =$("#txtHoraObra-D").val();
  //var parcial  =$("#txtParcial-D").val(); txtCosto
  var parcial  =$("#txtCosto").val();
  var ubicacion  =$("#txtUbicacion").val();

  var dataString='proceso='+proceso+'&id='+id+'&diagnostico='+diagnostico+'&estado='+estado+'&repuestos='+repuestos;
  dataString+='&mano_obra='+mano_obra+ '&HoraObra=' + txtHoraObra + '&parcial='+parcial+'&ubicacion='+ubicacion+'&fecha_alta='+fecha_alta+'&fecha_retiro='+fecha_retiro;

  $.ajax({
     type:'POST',
     url:urlprocess,
     data: dataString,
     dataType: 'json',
     success: function(data){

        if(data=="Validado"){
        var cartItems = [];
        var txtID_I = id;
        $('.cart li').each(function() {
            var item = {
                id: $(this).data('id'),
                price: $(this).data('price'),
                quantity: $(this).data('quantity'),
				idOrden: txtID_I
            };
            cartItems.push(item);
        });
		
		console.log(cartItems);

        $.ajax({
            type:'POST',
            url:'web/ajax/ajxtaller.php',
            data: { cart: cartItems },
            dataType: 'json',
            success: function(response) {
                if (response.status === 'empty') {
                swal({
                 title: "Lo sentimos...",
                 text: "Hubo un error. Estatus empty.",
                 confirmButtonColor: "#EF5350",
                 type: "error"
                 });
                } else if (response.status === 'error') {
                   swal({
                     title: "Lo sentimos...",
                     text: "Hubo un error. Estatus Error.",
                     confirmButtonColor: "#EF5350",
                     type: "error"
                   });
                }else
                {		  
					
					swal({
						title: "¡Éxito!",
						text: "¡Diagnóstico registrado exitosamente!",
						icon: "success",
						confirmButtonColor: "#43ABDB",
						confirmButtonText: "Ok",
						closeOnConfirm: true
					}, function(isConfirm) {
						if (isConfirm) {
							$('.cart').empty(); // Limpia el carrito
							localStorage.clear();
							sessionStorage.clear();
							$('#modal_iconified2').modal('toggle'); // Cierra el modal
							location.reload(); // Recarga la página	
						}
					});			  
                ///cargarDiv("#reload-div","web/ajax/reload-taller.php?fecha1=empty&fecha2=empty"); -----------codigo original me da problemas con el cart
                limpiarform2();
                }

            },
        error: function(xhr, status, error) {
            swal({
                 title: "Lo sentimos...",
                 text: "Hubo un error. Estatus. "+ error,
                 confirmButtonColor: "#EF5350",
                 type: "error"
                 });
        console.log('Error: ' + error);
        console.log('XHR: ' + JSON.stringify(xhr));
        console.log('Status: ' + status);
        }

        });

        } else if (data=="Duplicado"){

           swal({
                  title: "Ops!",
                  text: "El dato que ingresaste ya existe",
                  confirmButtonColor: "#EF5350",
                  type: "warning"
           });


        } else if(data =="Error"){

               swal({
                title: "Lo sentimos...",
                text: "No procesamos bien tus datos!",
                confirmButtonColor: "#EF5350",
                type: "error"
            });
        }

     },error: function(data) {
        console.log(data);
         swal({
            title: "Lo sentimos...",
            text: "Algo sucedio mal!",
            confirmButtonColor: "#EF5350",
            type: "error"
        });


     }

  });

}


function cargarDiv(div,url)
{
      $(div).load(url);
}



function Print_Report(Criterio,Orden)
{

    if (Criterio == 'Orden') {

        window.open("reportes/Boleta_Taller.php?orden="+btoa(Orden),
       'win2',
       'status=yes,toolbar=yes,scrollbars=yes,titlebar=yes,menubar=yes,'+
       'resizable=yes,width=800,height=800,directories=no,location=no'+
       'fullscreen=yes');
    }



}

function SwalDelete(productId){
              swal({
                title: "¿Está seguro que desea borrar la orden?",
                text: "Este proceso es irreversible!",
                type: "warning",
                showCancelButton: true,
                confirmButtonColor: "#EF5350",
                confirmButtonText: "Si, Borrar",
                cancelButtonText: "No, volver atras",
                closeOnConfirm: false,
                closeOnCancel: false
            },
            function(isConfirm){
                if (isConfirm) {
                     return new Promise(function(resolve) {
                        $.ajax({
                        url: 'web/ajax/ajxtaller.php',
                        type: 'POST',
                        data: 'proceso=Borrar&numero_transaccion='+productId+'&numero_orden=null',
                        dataType: 'json'
                        })
                        .done(function(response){
                         swal('Eliminada!', response.message, response.status);
                          buscar_datos();
                        })
                        .fail(function(){
                         swal('Oops...', 'Algo salio mal al procesar tu peticion!', 'error');
                        });
                     });
                }
                else {
                    swal({
                        title: "Esta bien",
                        text: "Puedes seguir donde te quedaste",
                        confirmButtonColor: "#2196F3",
                        type: "info"
                    });
                }
            });

 }

function Print_Ticket_Regis(){
  var url = "reportes/Ticket_Taller.php?orden=''";
  var url2 = "reportes/Ticket_Taller_Aparato.php?orden=''";
  $('#ticket_frame').attr('src', url)
  $('#ticket2_frame').attr('src', url2)
  $('#modal_ticket').modal('show');

}

function Print_Ticket_Edit(orden){
    var url = "reportes/Ticket_Taller.php?orden="+btoa(orden);
    var url2 = "reportes/Ticket_Taller_Aparato.php?orden="+btoa(orden);
    $('#ticket_frame').attr('src', url)
    $('#ticket2_frame').attr('src', url2)
    $('#modal_ticket').modal('show');
}

function Print_Ticket(orden){
    var url = "reportes/Ticket_Taller.php?orden="+btoa(orden);
    var url2 = "reportes/Ticket_Taller_Aparato.php?orden="+btoa(orden);
    $('#ticket_frame').attr('src', url)
    $('#ticket2_frame').attr('src', url2)
}
