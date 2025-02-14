$(function() {

  $(document).on('click', '#print_activos', function(e){

       Print_Report('Activos');
       e.preventDefault();
  });

  $(document).on('click', '#print_inactivos', function(e){

       Print_Report('Inactivos');
       e.preventDefault();
 });

$(document).on('click', '#print_agotados', function(e){

       Print_Report('Agotados');
       e.preventDefault();
 });

$(document).on('click', '#print_vigentes', function(e){

       Print_Report('Vigentes');
       e.preventDefault();
 });


    // Table setup
    // ------------------------------

    // Setting datatable defaults
    $.extend($.fn.dataTable.defaults, {
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
        sZeroRecords: "No se encontraron resultados",
        sInfoEmpty: "No existen registros que contabilizar",
        sInfoFiltered: "(filtrado de un total de _MAX_ registros)",
        sInfo: "Mostrando del registro _START_ al _END_ de un total de _TOTAL_ datos",
        paginate: { 'first': 'First', 'last': 'Last', 'next': '&rarr;', 'previous': '&larr;' }
    },
    drawCallback: function () {
        $(this).find('tbody tr').slice(-3).find('.dropdown, .btn-group').addClass('dropup');
    },
    preDrawCallback: function () {
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


    jQuery.validator.addMethod("greaterThan",function (value, element, param) {
      var $min = $(param);
      if (this.settings.onfocusout) {
        $min.off(".validate-greaterThan").on("blur.validate-greaterThan", function () {
          $(element).valid();
        });
      }return parseInt(value) > parseInt($min.val());}, "Maximo debe ser mayor a minimo");

    jQuery.validator.addMethod("lettersonly", function(value, element) {
         return this.optional(element) || /^[a-z\s 0-9 , . / () # -]+$/i.test(value);
    }, "No se permiten caracteres especiales");


     var validator2 = $("#frmPrint").validate({

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
        txtProductoP:{
          required: true
        },
        txtCodigoBarraP:{
          required: true
        },
        txtCant:{
          required: true
        },
        txtAncho:{
          required:true
        },
        txtAlto:{
          required: true
        }
      },
    validClass: "validation-valid-label",
     success: function(label) {
          label.addClass("validation-valid-label").text("Correcto.")
      },

       submitHandler: function (form) {
           Imprimir_Barra();
        }
     });



     var validator = $("#frmModal").validate({

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
        txtProducto:{
          maxlength:175,
          minlength: 4,
          required: true,
          lettersonly:false
        },
        txtPCompra:{
          required: true
        },
        txtPVenta:{
          required: true
        },
        txtPVenta1:{
          required: false
        },
        txtPVenta2:{
          required: false
        },
        txtPVenta3:{
          required: false
        },
        txtPVentaM:{
          required: true
        },
        txtStock:{
          required:true
        },
        txtSMin:{
          required: true
        },
        cbCategoria:{
          required: true
        },
        cbPresentacion:{
          required: false
        },
      },
    validClass: "validation-valid-label",
     success: function(label) {
          label.addClass("validation-valid-label").text("Correcto.")
      },

       submitHandler: function (form) {
           enviar_frm();
        }
     });

       var form = $('#frmModal');

       $('#cbCategoria', form).change(function () {
            form.validate().element($(this)); //revalidate the chosen dropdown value and show error or success message for the input
        });

       $('#cbPresentacion', form).change(function () {
            form.validate().element($(this)); //revalidate the chosen dropdown value and show error or success message for the input
        });

    $('#btnEditar').hide();

    // Prefix
    $("#txtPCompra").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '$'
    });

    $("#txtPVenta").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '$'
    });

    $("#txtPVenta1").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '$'
    });

    $("#txtPVenta2").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '$'
    });

    $("#txtPVenta3").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '$'
    });

    $("#txtPVentaM").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '$'
    });

    $("#txtSMin").TouchSpin({
        min: 0,
        max: 100000000,
        step: 1,
        decimals: 0,
        prefix: '<i class="icon-box-add"></i>'
    });

    $("#txtStock").TouchSpin({
        min: 0,
        max: 100000000,
        step: 1,
        decimals: 0,
        prefix: '<i class="icon-box"></i>'
    });

    $("#txtCant").TouchSpin({
        min: 0,
        max: 100000000,
        step: 5,
        decimals: 0
    });

    $("#txtAncho").TouchSpin({
        min: 0.00,
        max: 40.00,
        step: 0.01,
        decimals: 2,
        prefix: '<i class="icon-rulers"></i>'
    });

    $("#txtAlto").TouchSpin({
        min: 0.00,
        max: 100000000,
        step: 0.01,
        decimals: 2,
        prefix: '<i class="icon-rulers"></i>'
    });

    $('.select-search').select2();

        // Default initialization
    $(".styled, .multiselect-container input").uniform({
        radioClass: 'choice'
    });

        /*Evento change de ChkEstado en el cual al chequear o deschequear cambia el label*/
    $("#chkEstado").change(function() {
        if(this.checked) {
           $("#chkEstado").val(true);
           document.getElementById("lblchk").innerHTML = 'VIGENTE';
        } else {
          $("#chkEstado").val(false);
          document.getElementById("lblchk").innerHTML = 'DESCONTINUADA';
        }
    });

    $("#chkPerece").change(function() {
        if(this.checked) {
           $("#chkPerece").val(true);
           document.getElementById("lblchk-p").innerHTML = 'PERECEDERO';
        } else {
          $("#chkPerece").val(false);
          document.getElementById("lblchk-p").innerHTML = 'NO PERECEDERO';
        }
    });

    $("#chkExento").change(function() {
        if(this.checked) {
           $("#chkExento").val(true);
           document.getElementById("lblchk-e").innerHTML = 'SIN ITBMS';
        } else {
          $("#chkExento").val(false);
          document.getElementById("lblchk-e").innerHTML = 'CON ITBMS';
        }
    });

    $("#chkInven").change(function() {
        if(this.checked) {
           $("#chkInven").val(true);
           document.getElementById("lblchk-i").innerHTML = 'INVENTARIABLE';
        } else {
          $("#chkInven").val(false);
          document.getElementById("lblchk-i").innerHTML = 'NO INVENTARIABLE';
        }
    });

  $.fn.modal.Constructor.prototype.enforceFocus = function() {};


});

  function limpiarform(){

    var form = $( "#frmModal" ).validate();
    form.resetForm();

  }

  function setSwitchery(switchElement, checkedBool) {
    if((checkedBool && !switchElement.isChecked()) || (!checkedBool && switchElement.isChecked())) {
        switchElement.setPosition(true);
        switchElement.handleOnchange(true);
    }
}

function openBarcode(codigo_barra,codigo_alternativo,codigo_interno,nombre_producto,idproducto){

   $('#modal_iconified_barcode').on('shown.bs.modal', function () {

      $('#txtIDP').val(idproducto);
        if((codigo_barra == '') && (codigo_alternativo == '')) {
        $('#txtCodigoBarraP').val(codigo_interno);
      } else if ((codigo_barra != '') && (codigo_alternativo == '')) {
        $('#txtCodigoBarraP').val(codigo_barra);
      } else if ((codigo_barra == '') && (codigo_alternativo != '')){
        $('#txtCodigoBarraP').val(codigo_alternativo);
      } else if ((codigo_barra != '') && (codigo_alternativo != '')){
         $('#txtCodigoBarraP').val(codigo_barra);
      } else {
         $('#txtCodigoBarraP').val(codigo_interno);
      }


      $('#txtProductoP').val(nombre_producto);

      $('#txtCodigoBarraP').prop( "disabled" ,  true);
      $('#txtProductoP').prop( "disabled" ,  true);

      var modal = $(this);

       modal.find('.title-form').text('Imprimir Codigo de Barra');

   });


}


function newProducto()
 {
    openProducto('nuevo',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
    $('#modal_iconified').modal('show');
 }
function openProducto(action, idproducto, codigo_interno, codigo_barra, codigo_alternativo, nombre_producto, precio_compra,
    precio_venta, precio_venta1, precio_venta2, precio_venta3, precio_venta_mayoreo, stock, stock_min, idcategoria, idmarca,
    idpresentacion, estado, exento, inventariable, perecedero, imagen)

 {
      var mySwitch = new Switchery($('#chkEstado')[0], {
          size:"small",
          color: '#0D74E9'
      });

      /*var mySwitch2 = new Switchery($('#chkPerece')[0], {
          size:"small",
          color: '#8E24AA'
      });*/

      var mySwitch3 = new Switchery($('#chkExento')[0], {
          size:"small",
          color: '#03A9F4'
      });

      var mySwitch4 = new Switchery($('#chkInven')[0], {
          size:"small",
          color: '#8BC34A'
      });

    $('#modal_iconified').on('shown.bs.modal', function () {
     var modal = $(this);
     if (action == 'nuevo'){

      $('#txtProceso').val('Registro');
      $('#txtID').val('');
      $('#txtCodigo').val('');
      $('#txtCodigoBarra').val('');
      $('#txtCodigoAlt').val('');
      $('#txtProducto').val('');
      $('#txtStock').val('');
      $('#txtPCompra').val('');
      $('#txtPVenta').val('');
      $('#txtPVenta1').val('');
      $('#txtPVenta2').val('');
      $('#txtPVenta3').val('');
      $('#txtPVentaM').val('');
      $('#txtSMin').val('');
      $('#cimagen').val('');
      $('#imagen').val('');
	  $(".peditar").attr("src", "web/assets/images/no_img.jpg");
      $("#cbCategoria").select2("val", "All");
      $("#cbMarca").select2("val", "All");
      $("#cbPresentacion").select2("val", "All");
      setSwitchery(mySwitch, true);
      //setSwitchery(mySwitch2, false);
      setSwitchery(mySwitch3, false);
      setSwitchery(mySwitch4, true);

      $('#txtCodigo').prop( "disabled" , false);
      $('#txtCodigoBarra').prop( "disabled" , false);
      $('#txtCodigoAlt').prop( "disabled" , false);
      $('#txtProducto').prop( "disabled" , false);
      $('#txtStock').prop( "disabled" , false);
      $('#txtPCompra').prop( "disabled" , false);
      $('#txtPVenta').prop( "disabled" , false);
      $('#txtPVenta1').prop( "disabled" , false);
      $('#txtPVenta2').prop( "disabled" , false);
      $('#txtPVenta3').prop( "disabled" , false);
      $('#txtPVentaM').prop( "disabled" , false);
      $('#txtSMin').prop( "disabled" , false);
      $('#cbCategoria').prop( "disabled" , false);
      $('#cbMarca').prop( "disabled" , false);
      $('#cbPresentacion').prop( "disabled" , false);
      $('#chkEstado').prop( "disabled" , true);
      $('#chkPerece').prop( "disabled" , false);
      $('#chkExento').prop( "disabled" , false);
      $('#chkInven').prop( "disabled" , false);


      $('#btnEditar').hide();
      $('#btnGuardar').show();
      limpiarform();

      modal.find('.title-form').text('Ingresar Producto');
     }else if(action=='editar') {

      $('#modal_iconified').modal('show');

      $('#txtProceso').val('Edicion');
      $('#txtID').val(idproducto);
      $('#txtCodigo').val(codigo_interno);
      $('#txtCodigoBarra').val(codigo_barra);
      $('#txtCodigoAlt').val(codigo_alternativo);
      $('#txtProducto').val(nombre_producto);
      $('#txtStock').val(stock);
      $('#txtPCompra').val(precio_compra);
      $('#txtPVenta').val(precio_venta);
      $('#txtPVenta1').val(precio_venta1);
      $('#txtPVenta2').val(precio_venta2);
      $('#txtPVenta3').val(precio_venta3);
      $('#txtPVentaM').val(precio_venta_mayoreo);
      $('#txtSMin').val(stock_min);
      $("#cbCategoria").val(idcategoria).trigger("change");
      $("#cbMarca").val(idmarca).trigger("change");
      $("#cbPresentacion").val(idpresentacion).trigger("change");
		if(imagen!= ''){
				$(".peditar").attr("src", "web/images_productos/"+imagen);
			}else{
				$(".peditar").attr("src", "web/assets/images/no_img.jpg");
			}
	 $('#cimagen').val(imagen);
	 
      if (estado == '1')
        {
          $("#chkEstado").val(true);
          //setSwitchery(mySwitch, true);
          //document.getElementById("chkEstado").checked = true;
          //document.getElementById("lblchk").innerHTML = 'VIGENTE';
        }else {
          $("#chkEstado").val(false);
          //setSwitchery(mySwitch, false);
          //document.getElementById("chkEstado").checked = false;
          //document.getElementById("lblchk").innerHTML = 'DESCONTINUADO';
        }

       if (perecedero == '1')
        {
          $("#chkPerece").val(true);
          //setSwitchery(mySwitch2, true);
          //document.getElementById("chkPerece").checked = true;
          //document.getElementById("lblchk-p").innerHTML = 'PERECEDERO';
        }else {
          $("#chkPerece").val(false);
          //setSwitchery(mySwitch2, false);
          //document.getElementById("chkPerece").checked = false;
          //document.getElementById("lblchk-p").innerHTML = 'NO PERECEDERO';
        }

        if (exento == '1')
          {
            $("#chkExento").val(true);
            setSwitchery(mySwitch3, true);
            document.getElementById("chkExento").checked = true;
            document.getElementById("lblchk-e").innerHTML = 'SIN ITBMS';
          }else {
            $("#chkExento").val(false);
            setSwitchery(mySwitch3, false);
            document.getElementById("chkExento").checked = false;
            document.getElementById("lblchk-e").innerHTML = 'CON ITBMS';
          }

        if (inventariable == '1')
        {
          $("#chkInven").val(true);
          setSwitchery(mySwitch4, true);
          document.getElementById("chkInven").checked = true;
          document.getElementById("lblchk-i").innerHTML = 'INVENTARIABLE';
        }else {
          $("#chkInven").val(false);
          setSwitchery(mySwitch4, false);
          document.getElementById("chkInven").checked = false;
          document.getElementById("lblchk-i").innerHTML = 'NO INVENTARIABLE';
        }

      $('#txtCodigo').prop( "disabled" , false);
      $('#txtCodigoBarra').prop( "disabled" , false);
      $('#txtCodigoAlt').prop( "disabled" , false);
      $('#txtProducto').prop( "disabled" , false);
      $('#txtStock').prop( "disabled" , true);
      $('#txtPCompra').prop( "disabled" , false);
      $('#txtPVenta').prop( "disabled" , false);
      $('#txtPVenta1').prop( "disabled" , false);
      $('#txtPVenta2').prop( "disabled" , false);
      $('#txtPVenta3').prop( "disabled" , false);
      $('#txtPVentaM').prop( "disabled" , false);
      $('#txtSMin').prop( "disabled" , false);
      $('#cbCategoria').prop( "disabled" , false);
      $('#cbMarca').prop( "disabled" , false);
      $('#cbPresentacion').prop( "disabled" , false);
      $('#chkEstado').prop( "disabled" , false);
      $('#chkPerece').prop( "disabled" , false);
      $('#chkExento').prop( "disabled" , false);
      $('#chkInven').prop( "disabled" , false);

      $('#btnEditar').show();
      $('#btnGuardar').hide();

      modal.find('.title-form').text('Actualizar Producto');
     } else if(action=='ver'){
      $('#txtProceso').val('');
      $('#txtID').val(idproducto);
      $('#txtCodigo').val(codigo_interno);
      $('#txtCodigoBarra').val(codigo_barra);
      $('#txtCodigoAlt').val(codigo_alternativo);
      $('#txtProducto').val(nombre_producto);
      $('#txtStock').val(stock);
      $('#txtPCompra').val(precio_compra);
      $('#txtPVenta').val(precio_venta);
      $('#txtPVenta1').val(precio_venta1);
      $('#txtPVenta2').val(precio_venta2);
      $('#txtPVenta3').val(precio_venta3);
      $('#txtPVentaM').val(precio_venta_mayoreo);
      $('#txtSMin').val(stock_min);
      $("#cbCategoria").val(idcategoria).trigger("change");
      $("#cbMarca").val(idmarca).trigger("change");
      $("#cbPresentacion").val(idpresentacion).trigger("change");
		if(imagen!= ''){
				$(".peditar").attr("src", "web/images_productos/"+imagen);
			}else{
				$(".peditar").attr("src", "web/assets/images/no_img.jpg");
			}
      if (estado == '1')
        {
          $("#chkEstado").val(true);
          //setSwitchery(mySwitch, true);
          //document.getElementById("chkEstado").checked = true;
          //document.getElementById("lblchk").innerHTML = 'VIGENTE';
        }else {
          $("#chkEstado").val(false);
          //setSwitchery(mySwitch, false);
          //document.getElementById("chkEstado").checked = false;
          //document.getElementById("lblchk").innerHTML = 'DESCONTINUADO';
        }

       if (perecedero == '1')
        {
          $("#chkPerece").val(true);
          //setSwitchery(mySwitch2, true);
          //document.getElementById("chkPerece").checked = true;
          //document.getElementById("lblchk-p").innerHTML = 'PERECEDERO';
        }else {
          $("#chkPerece").val(false);
          //setSwitchery(mySwitch2, false);
          //document.getElementById("chkPerece").checked = false;
          //document.getElementById("lblchk-p").innerHTML = 'NO PERECEDERO';
        }

        if (exento == '1')
          {
            $("#chkExento").val(true);
            setSwitchery(mySwitch3, true);
            document.getElementById("chkExento").checked = true;
            document.getElementById("lblchk-e").innerHTML = 'SIN ITBMS';
          }else {
            $("#chkExento").val(false);
            setSwitchery(mySwitch3, false);
            document.getElementById("chkExento").checked = false;
            document.getElementById("lblchk-e").innerHTML = 'CON ITBMS';
          }

        if (inventariable == '1')
        {
          $("#chkInven").val(true);
          setSwitchery(mySwitch4, true);
          document.getElementById("chkInven").checked = true;
          document.getElementById("lblchk-i").innerHTML = 'INVENTARIABLE';
        }else {
          $("#chkInven").val(false);
          setSwitchery(mySwitch4, false);
          document.getElementById("chkInven").checked = false;
          document.getElementById("lblchk-i").innerHTML = 'NO INVENTARIABLE';
        }


      $('#txtCodigo').prop( "disabled" , true);
      $('#txtCodigoBarra').prop( "disabled" , true);
      $('#txtCodigoAlt').prop( "disabled" , true);
      $('#txtProducto').prop( "disabled" , true);
      $('#txtStock').prop( "disabled" , true);
      $('#txtPCompra').prop( "disabled" , true);
      $('#txtPVenta').prop( "disabled" , true);
      $('#txtPVenta1').prop( "disabled" , true);
      $('#txtPVenta2').prop( "disabled" , true);
      $('#txtPVenta3').prop( "disabled" , true);
      $('#txtPVentaM').prop( "disabled" , true);
      $('#txtSMin').prop( "disabled" , true);
      $('#cbCategoria').prop( "disabled" , true);
      $('#cbMarca').prop( "disabled" , true);
      $('#cbPresentacion').prop( "disabled" , true);
      $('#chkEstado').prop( "disabled" , true);
      $('#chkPerece').prop( "disabled" , true);
      $('#chkExento').prop( "disabled" , true);
      $('#chkInven').prop( "disabled" , true);


      $('#btnEditar').hide();
      $('#btnGuardar').hide();

      modal.find('.title-form').text('Ver Producto');
     }

  });

}

function enviar_frm()
{
  var urlprocess = 'web/ajax/ajxproducto.php';
  var proceso = $("#txtProceso").val();
  var id = $("#txtID").val();
  var codigo_barra =$("#txtCodigoBarra").val();
  var codigo_alternativo =$("#txtCodigoAlt").val();
  var nombre_producto =$("#txtProducto").val();
  var precio_compra  =$("#txtPCompra").val();
  var precio_venta =$("#txtPVenta").val();
  var precio_venta1 =$("#txtPVenta1").val();
  var precio_venta2 =$("#txtPVenta2").val();
  var precio_venta3 =$("#txtPVenta3").val();
  var precio_venta_mayoreo  =$("#txtPVentaM").val();
  var stock = $("#txtStock").val();
  var stock_min =$("#txtSMin").val();
  var idcategoria  =$("#cbCategoria").val();
  var idmarca  =$("#cbMarca").val();
  var idpresentacion  =$("#cbPresentacion").val();
  var estado = $('#chkEstado').is(':checked') ? 1 : 0;
  var exento = $('#chkExento').is(':checked') ? 1 : 0;
  var perecedero = $('#chkPerece').is(':checked') ? 1 : 0;
  var inventariable = $('#chkInven').is(':checked') ? 1 : 0;
if($("#cimagen").val() !=''){
		var cimagen =$("#cimagen").val();
		}else{
		var cimagen ='';	
		}
    idpresentacion = 1; //valor por defecto ya que el campo es obligatorio pero lo quieren oculto 
if($("#txtImagen").val() !=''){
		var imagen = $("#txtImagen")[0].files[0].name;
		}else{
		var imagen ='';	
		}
		console.log(cimagen);
if (idmarca == null){idmarca = '';}
  
  var dataString='proceso='+proceso+'&id='+id+'&codigo_barra='+codigo_barra+'&codigo_alternativo='+codigo_alternativo+'&nombre_producto='+nombre_producto+'&precio_compra='+precio_compra;
  dataString+='&precio_venta='+precio_venta+'&precio_venta1='+precio_venta1+'&precio_venta2='+precio_venta2+'&precio_venta3='+precio_venta3+'&precio_venta_mayoreo='+precio_venta_mayoreo;
  dataString+='&stock='+stock+'&stock_min='+stock_min+'&idcategoria='+idcategoria+'&idmarca='+idmarca+'&idpresentacion='+idpresentacion+'&estado='+estado+'&exento='+exento+'&inventariable='+inventariable+'&perecedero='+perecedero+'&imagen='+imagen+'&cimagen='+cimagen;

  console.log(dataString);
  $.ajax({
     type:'POST',
     url:urlprocess,
     data: dataString,
     dataType: 'json',
     success: function(data){

        if(data=="Validado"){
             if(proceso=="Registro"){
			 var formData = new FormData($("#frmModal")[0]);
			  $.ajax({
			  type: 'POST',
			  url: 'subida.php?op='+proceso,
			  data: formData,
			  contentType: false,
			  processData: false
			  });
              swal({
                  title: "Exito!",
                  text: "Producto registrado",
                  confirmButtonColor: "#66BB6A",
                  type: "success"
              },
					 function(){ 
						 window.location.reload();
					 });

              $('#modal_iconified').modal('toggle');

              cargarDiv("#reload-div","web/ajax/reload-producto.php");
              limpiarform();
			  

              } else if(proceso == "Edicion") {
				  var formData = new FormData($("#frmModal")[0]);
					  $.ajax({
					  type: 'POST',
					  url: 'subida.php?op='+proceso,
					  data: formData,
					  contentType: false,
					  processData: false
					  });
                  swal({
                      title: "Exito!",
                      text: "Producto modificado",
                      confirmButtonColor: "#2196F3",
                      type: "info"
                  },
					 function(){ 
						 window.location.reload();
					 });
                   $('#modal_iconified').modal('toggle');
                  cargarDiv("#reload-div","web/ajax/reload-producto.php");
              }

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

     },error: function() {
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

function Print_Report(Criterio)
{

  if(Criterio == 'Activos')
  {
       window.open('reportes/Productos_Activos.php',
      'win2',
      'status=yes,toolbar=yes,scrollbars=yes,titlebar=yes,menubar=yes,'+
      'resizable=yes,width=800,height=800,directories=no,location=no'+
      'fullscreen=yes');

  } else if (Criterio == 'Inactivos') {

       window.open('reportes/Productos_Inactivos.php',
      'win2',
      'status=yes,toolbar=yes,scrollbars=yes,titlebar=yes,menubar=yes,'+
      'resizable=yes,width=600,height=600,directories=no,location=no'+
      'fullscreen=yes');

  } else if (Criterio == 'Agotados') {

       window.open('reportes/Productos_Agotados.php',
      'win2',
      'status=yes,toolbar=yes,scrollbars=yes,titlebar=yes,menubar=yes,'+
      'resizable=yes,width=600,height=600,directories=no,location=no'+
      'fullscreen=yes');

  } else if (Criterio == 'Vigentes'){

       window.open('reportes/Productos_Vigentes.php',
      'win2',
      'status=yes,toolbar=yes,scrollbars=yes,titlebar=yes,menubar=yes,'+
      'resizable=yes,width=600,height=600,directories=no,location=no'+
      'fullscreen=yes');
  }



}

function Imprimir_Barra(){

      var id = $("#txtIDP").val();
      var cant = $("#txtCant").val();
      var ancho = $("#txtAncho").val();
      var alto = $("#txtAlto").val();

      window.open('reportes/Print_Barras.php?ref='+btoa(id)+'&ancho='+ancho+'&alto='+alto+'&cant='+cant,
      'win2',
      'status=yes,toolbar=yes,scrollbars=yes,titlebar=yes,menubar=yes,'+
      'resizable=yes,width=900,height=600,directories=no,location=no'+
      'fullscreen=yes');
}

    function accion(accion) {
        console.log("Acción seleccionada:", accion); // Verificar la acción seleccionada en la consola del navegador

        // Verifica si la acción es 'exportar_csv'
        if (accion === 'exportar_csv') {
            console.log("Exportando a CSV..."); // Verificar si la condición 'if' se cumple
            var form = document.createElement('form');
            form.method = 'POST';
            form.action = 'http://localhost/silverngrok/gesnet_proyect/web/ajax/exportar_csv.php'; // Nombre del archivo PHP que manejará la exportación a CSV

            var input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'accion';
            input.value = accion;

            form.appendChild(input);
            document.body.appendChild(form);
            form.submit();
        }
         if (accion === 'exportar_excel') {
            console.log("Exportando a EXCEL..."); // Verificar si la condición 'if' se cumple
            var form = document.createElement('form');
            form.method = 'POST';
            form.action = 'http://localhost/silverngrok/gesnet_proyect/web/ajax/exportar_excel.php'; // Nombre del archivo PHP que manejará la exportación a CSV

            var input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'accion';
            input.value = accion;

            form.appendChild(input);
            document.body.appendChild(form);
            form.submit();
        }
    }

        // Función para seleccionar archivo CSV
    function seleccionarArchivo() {
        // Mostrar el cuadro de diálogo de selección de archivos
        document.getElementById('archivo_input').click();
    }
        
// Función para enviar el archivo seleccionado al servidor
document.getElementById('archivo_input').addEventListener('change', function() {
    var archivo = this.files[0];
    var formData = new FormData();
    formData.append('archivo_csv', archivo); // Cambia 'archivo_temporal' por el nombre correcto

    // Realizar una solicitud HTTP POST al archivo importar_csv.php en el servidor web
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/silverngrok/gesnet_proyect/web/ajax/importar_csv.php', true); // URL relativa
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                var response = JSON.parse(xhr.responseText);
                handleServerResponse(response);
            } catch (e) {
                console.error('Error al parsear JSON:', e);
                console.error('Respuesta del servidor:', xhr.responseText);
                alert('Error en archivo, no es posible importar.');
            }
        } else {
            alert('Error en la solicitud al servidor.');
        }
    };

    xhr.send(formData);
});

function handleServerResponse(response) {
        if (response.success) {
            alert(response.message);
            actualizarTablaDespuesDeImportarCSV();
        } else {
            alert(response.message);
        }
    }


// Realizar una solicitud AJAX para actualizar la tabla después de importar el CSV
function actualizarTablaDespuesDeImportarCSV() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/silverngrok/gesnet_proyect/web/ajax/actualizar_tabla.php', true);
    xhr.onload = function() {
        if (xhr.status === 200)  {
            // Actualizar el contenido de la tabla en la página actual
            document.getElementById('DataTables_Table_0').innerHTML = xhr.responseText;
	    location.reload();
        } else {
             alert('Error al actualizar.');
        }
    };
    xhr.send();
}

document.getElementById('archivo_excel').addEventListener('change', function() {
    var archivo = this.files[0];
    var formData = new FormData();
    formData.append('archivo_excel', archivo);

    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/silverngrok/gesnet_proyect/web/ajax/importar_excel.php', true); // URL relativa
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                var response = JSON.parse(xhr.responseText);
                handleServerResponse(response);
		location.reload();
            } catch (e) {
                console.error('Error al parsear JSON:', e);
                console.error('Respuesta del servidor:', xhr.responseText);
                alert('Error en archivo, no es posible importar.');
            }
        } else {
            console.error('Error de red:', xhr.status, xhr.statusText);
            alert('La respuesta del servidor está vacía.');
        }
    };

    xhr.onerror = function() {
        console.error('Error de red');
        alert('Error de red. No se pudo enviar la solicitud.');
};

xhr.send(formData);
});

function handleServerResponse(response) {
    if (response.success) {
        alert(response.message);
        actualizarTablaDespuesDeImportarCSV();
    } else {
        alert(response.message);
    }
}

function Historial()
 {
    openHistorial();
    $('#modal_historial').modal('show');
 }

function openHistorial()

 {
    $('#modal_iconified').on('shown.bs.modal', function () {
     var modal = $(this);
     
      modal.find('.title-form').text('Historial');

  });

}


