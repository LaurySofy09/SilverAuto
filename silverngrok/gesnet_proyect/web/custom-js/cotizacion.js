$(function() {

  $(".switch").bootstrapSwitch();
  //
  // Single select with icons
  //

  // Format icon
  function iconFormat(icon) {
      var originalOption = icon.element;
      if (!icon.id) { return icon.text; }
      var $icon = "<i class='icon-" + $(icon.element).data('icon') + "'></i>" + icon.text;

      return $icon;
  }

  // Initialize with options
    $(".select-icons").select2({
        containerCssClass: 'bg-orange-800',
        templateResult: iconFormat,
        minimumResultsForSearch: Infinity,
        templateSelection: iconFormat,
        escapeMarkup: function(m) { return m; }
    });

    // Initialize with options
    $(".select-icons-search").select2({
        containerCssClass: 'bg-info-400',
        templateResult: iconFormat,
        minimumResultsForSearch: Infinity,
        templateSelection: iconFormat,
        escapeMarkup: function(m) { return m; }
    });


    jQuery.validator.addMethod("greaterThan",function (value, element) {
      var $min = $("#txtDeuda");
      if (this.settings.onfocusout) {
        $min.off(".validate-greaterThan").on("blur.validate-greaterThan", function () {
          $(element).valid();
        });
      }return parseFloat(value) >= parseFloat($min.val());}, "Debe ser mayor a deuda");


     var validator = $("#frmPago").validate({

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

        cbCliente:{
          required:true
        },
      },
      messages: {
          cbCliente: {
              required: "Debe Seleccionar un Cliente",
          }
      },

    validClass: "validation-valid-label",
     /*success: function(label) {
          label.addClass("validation-valid-label").text("Correcto.")
      },*/
       submitHandler: function (form) {
         enviar_data();
        }
     })

    var form = $('#frmPago');
     $('#cbCliente', form).change(function () {
          form.validate().element($(this)); //revalidate the chosen dropdown value and show error or success message for the input
      });

     $('#cbComprop', form).change(function () {
          form.validate().element($(this)); //revalidate the chosen dropdown value and show error or success message for the input
      });

      function limpiarform(){
        var form = $( "#frmPago" ).validate();
        form.resetForm();
      }



//**-------- Instanciando Select Cliente
    $('.select-size-xs').select2();
    $("#cbCliente").select2("val", "All");


        $("#buscar_producto").val("");
        $.getJSON('web/ajax/ajxparametro.php?criterio=moneda',function(data){
          $.each(data,function(key,val){
            var moneda = val.CurrencyISO + ' ' + val.Symbol;
              $("#big_total").html(moneda + ' 0.00');
          });
        });
        $("#totales_foot").hide();
        $("#btnguardar").hide();
        $("#btncancelar").hide();


        // Evento Change de chkPagado
       $("#chkPagado").change(function() {
          if(this.checked) {
             $("#chkPagado").val(true);
             document.getElementById("lblchk2").innerHTML = 'AL CONTADO';
          } else {
            $("#chkPagado").val(false);
            document.getElementById("lblchk2").innerHTML = 'AL CREDITO';
          }
       })

buscar_por_detalle();


}); // end function ready

$(document).ready(function() {

   //correoCotizacion();
});

function correoCotizacion()
{
    
    $.ajax({
        url: 'web/ajax/ajxCorreo.php',
        cache: false,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function(data) {
            // Manejar la respuesta del servidor
           /* if (response.status === 'success') {
                console.log('Correo enviado correctamente.');
            } else {
                console.log('Error al enviar el correo electrónico. ' + response.message);
            }*/
            console.log(data);
        },
        error: function ajaxError(result) {
            console.log(result.status + ' : ' + result.statusText + ' : ' + result.responseText);
        }
    });

}


var mySwitch = new Switchery($('#chkBusqueda')[0], {
    size:"small",
    color: '#1fccef',
    secondaryColor: '#0095f2'
});


function limpiarform(){
  var form = $( "#frmPago" ).validate();
  form.resetForm();
}

$('#modal_iconified_cash').on('hidden.bs.modal', function () {
    $("#cbCliente").select2("val", "All");
    limpiarform();
})



var mySwitch = new Switchery($('#chkPagado')[0], {
    size:"small",
    color: '#19AA8D',
    secondaryColor: '#3cb9e9'
});


 // Evento Change de chkBusqueda
/*$("#chkBusqueda").change(function() {
   if(this.checked) {
      $("#chkBusqueda").val(true);
      document.getElementById("lblchk3").innerHTML = ' PRODUCTO POR CODIGO';
      $("#buscar_producto").val('');
      buscar_por_codigo();
   } 
   else {
     $("#chkBusqueda").val(false);
     document.getElementById("lblchk3").innerHTML = 'PRODUCTO POR DETALLE';
     $("#buscar_producto").val('');
     buscar_por_detalle();
   }
})*/

$("#chkBusqueda").change();

//---------************* Agrego al detalle
function agregar_detalle(idproducto,producto,especificacion,precio_venta,precio_venta1,precio_venta2,precio_venta3,exento,stock,perecedero){
    var tr_add="";
    var id_previo = new Array();
    var filas=0;

      $("#tbldetalle tr").each(function (index){

         if (index>0){

         var campo0, campo1;
          $(this).children("td").each(function (index2){

            switch(index2){

            case 0:
            campo0 = $(this).text();
            if(campo0!=undefined || campo0!=''){
                id_previo.push(campo0);
            }
            break;

            case 1:
            break;

            case 2:
            break;

            case 3:
            break;

            case 4:
            break;

            case 5:
            break;

            case 6:
            break;

            case 7:
            break;

            } // end switch index 2

          }); // end each td

           filas=filas+1;

         } // if index > 0

      }); // end each tbldetalle tr


      if(stock == 0){

             tr_add += '<tr>';
                 tr_add += '<td align="center">'+idproducto+'</td>';
                 tr_add += '<td><h8 class="no-margin">'+producto+'</h8><br>'+
                '<span class="text-muted">'+especificacion+'</span></td>';
                 tr_add += '<td width="5%"><input type="text" id="tblcant" name="tblcant" value="1" class="touchspin" style="width:70px;"></td>';
                 tr_add += '<td align="center">';
                 tr_add += '<select name="ddl-precio" class="ddl-precio_venta">';
                 tr_add += '<option value="' + precio_venta + '">' + precio_venta + '</option>';
                 tr_add += '<option value="' + precio_venta1 + '">' + precio_venta1 + '</option>';
                 tr_add += '<option value="' + precio_venta2 + '">' + precio_venta2 + '</option>';
                 tr_add += '<option value="' + precio_venta3 + '">' + precio_venta3 + '</option>';
                 tr_add += '</select>';
                 tr_add += '</td>';
                 tr_add += '<td class="exento" id="exento" align="center">'+exento+'</td>';
                 tr_add += '<td width="5%"><input type="text" id="tbldesc" name="tbldesc"  value="0.00" class="touchspin" style="width:70px;"></td>';
                 tr_add += '<td class="precio_venta_nuevo" align="center">'+precio_venta+'</td>';
                 tr_add += '<td align="center">/</td>';
                 tr_add += '<td align="center" class="Delete"><button type="button"class="btn btn-link btn-xs"><i class="icon-trash-alt"></i></button></td>';
                 tr_add += '</tr>';

             var existe = false;
             var posicion_fila = 0;

             $.each(id_previo, function(i,id_prod_ant){
                 if(idproducto==id_prod_ant){
                   existe = true;
                   posicion_fila=i;
               }
             });

             if(existe==false){

               $("#tbldetalle").append(tr_add);

               $("#tbldetalle").on('change', '.ddl-precio_venta', function () {
                  var seleccionado = this.value;

                  var fila = $(this).closest('tr');
                  var celdaPrecio = fila.find('.precio_venta_nuevo');
                  if (celdaPrecio.length > 0) {
                      celdaPrecio.text(seleccionado);
                  }

                  totales(true);
                  });

               $("#buscar_producto").val('');
               // Prefix

               $('.select-size-xs').select2();

               $("input[name='tblcant']").TouchSpin({
                   verticalbuttons: true,
                   verticalupclass: 'icon-arrow-up22',
                   verticaldownclass: 'icon-arrow-down22',
                   min: 1,
                   max: 100000000000,
                   step: 1,
                   decimals: 0,
               }).on('touchspin.on.startspin', function () {totales()});

               $("input[name='tbldesc']").TouchSpin({
                   prefix:'$',
                   verticalbuttons: true,
                   verticalupclass: 'icon-arrow-up22',
                   verticaldownclass: 'icon-arrow-down22',
                   min: 0.00,
                   step: 0.01,
                   max: precio_venta,
                   decimals: 2,
               }).on('touchspin.on.startspin', function () {totales()});;

                noty({
                       force: true,
                       text: 'Producto agregado!',
                       type: 'information',
                       layout: 'top',
                       timeout: 500,
                   });

               totales();

             } else if(existe==true) {

                posicion_fila=posicion_fila+1;
                setRowCant(posicion_fila);

                noty({
                       force: true,
                       text: 'Producto agregado!',
                       type: 'information',
                       layout: 'top',
                       timeout: 500,
                   });

             }



      } else if (stock > 0.00){


         tr_add += '<tr>';
         tr_add += '<td align="center">'+idproducto+'</td>';
         tr_add += '<td><h8 class="no-margin">'+producto+'</h8><br>'+
        '<span class="text-muted">'+especificacion+'</span></td>';
         tr_add += '<td width="5%"><input type="text" id="tblcant" name="tblcant" value="1" class="touchspin" style="width:70px;"></td>';

         // Crear el Dropdown List para precio_venta
        tr_add += '<td align="center">';
        tr_add += '<select name="ddl-precio" class="ddl-precio_venta">';
        tr_add += '<option value="' + precio_venta + '">' + precio_venta + '</option>';
        tr_add += '<option value="' + precio_venta1 + '">' + precio_venta1 + '</option>';
        tr_add += '<option value="' + precio_venta2 + '">' + precio_venta2 + '</option>';
        tr_add += '<option value="' + precio_venta3 + '">' + precio_venta3 + '</option>';
        tr_add += '</select>';
        tr_add += '</td>';

         tr_add += '<td class="exento" id="exento" align="center">'+exento+'</td>';
         tr_add += '<td width="5%"><input type="text" id="tbldesc" name="tbldesc"  value="0.00" class="touchspin" style="width:70px;"></td>';
         tr_add += '<td class="precio_venta_nuevo" align="center">'+precio_venta+'</td>';
         tr_add += '<td align="center">/</td>';
         tr_add += '<td align="center" class="Delete"><button type="button"class="btn btn-link btn-xs"><i class="icon-trash-alt"></i></button></td>';
         tr_add += '</tr>';


        var existe = false;
        var posicion_fila = 0;

        $.each(id_previo, function(i,id_prod_ant){
            if(idproducto==id_prod_ant){
              existe = true;
              posicion_fila=i;
          }
        });

        if(existe==false){

          $("#tbldetalle").append(tr_add);

           $("#tbldetalle").on('change', '.ddl-precio_venta', function () {

                var seleccionado = this.value;

                var fila = $(this).closest('tr');
                var celdaPrecio = fila.find('.precio_venta_nuevo');
                if (celdaPrecio.length > 0) {
                    celdaPrecio.text(seleccionado);
                }

                totales(true);
            });

          $("#buscar_producto").val('');
          // Prefix

          $('.select-size-xs').select2();

          $("input[name='tblcant']").TouchSpin({
              verticalbuttons: true,
              verticalupclass: 'icon-arrow-up22',
              verticaldownclass: 'icon-arrow-down22',
              min: 1,
              max: 100000000000,
              step: 1,
              decimals: 0,
          }).on('touchspin.on.startspin', function () {totales()});

          $("input[name='tbldesc']").TouchSpin({
              prefix:'$',
              verticalbuttons: true,
              verticalupclass: 'icon-arrow-up22',
              verticaldownclass: 'icon-arrow-down22',
              min: 0.00,
              step: 0.01,
              
              decimals: 2,
          }).on('touchspin.on.startspin', function () {totales()});;

           noty({
                  force: true,
                  text: 'Producto agregado!',
                  type: 'information',
                  layout: 'top',
                  timeout: 500,
              });

          totales();

        } else if(existe==true) {

           posicion_fila=posicion_fila+1;
           setRowCant(posicion_fila);

           noty({
                  force: true,
                  text: 'Producto agregado!',
                  type: 'information',
                  layout: 'top',
                  timeout: 500,
              });

        }


  } // else if perecedero

}
//-----------Agregar al Detalle


// reemplazar valores de celda cantidades
function setRowCant(rowId){
    var cantidad_anterior=$('#tbldetalle tr:nth-child('+rowId+')').find('td:eq(2)').find("#tblcant").val();
    var cantidad_nueva= parseFloat(cantidad_anterior)+1;
    $('#tbldetalle tr:nth-child('+rowId+')').find('td:eq(2)').find("#tblcant").val(cantidad_nueva.toFixed(2));
    totales();
};


function buscar_por_detalle()
{
  $("#buscar_producto").autocomplete({
    minLength: 1,
    source: "web/ajax/autocomplete_venta.php",

    focus: function( event, ui ) {
     // $("#buscar_producto").val(ui.item.label);
      return false;
    },

       select: function( event, ui ) {
        var tipo_precio = $('#chkPrecio').is(':checked') ? 1 : 0;
        var idproducto = ui.item.value;
        var producto = ui.item.producto;
        var precio_venta = ui.item.precio_venta;
        var precio_venta1 = ui.item.precio_venta1;
        var precio_venta2 = ui.item.precio_venta2;
        var precio_venta3 = ui.item.precio_venta3;
        var precio_venta_mayoreo = ui.item.precio_venta_mayoreo;
        var datos = ui.item.datos;
        var exento = ui.item.exento;
        var stock = ui.item.stock;
        var perecedero = ui.item.perecedero;
        var inventariable = ui.item.inventariable;

        if(inventariable == 0){

          agregar_detalle(idproducto,producto,datos,precio_venta,precio_venta1,precio_venta2,precio_venta3,0.00,stock,perecedero,inventariable);
        
        } else if (inventariable == 1){


            if(exento == 0)
            {
              if(tipo_precio == 1)
              {
                agregar_detalle(idproducto,producto,datos,precio_venta,precio_venta1,precio_venta2,precio_venta3,0.00,stock,perecedero,inventariable);

              } else if (tipo_precio == 0){

                agregar_detalle(idproducto,producto,datos,precio_venta_mayoreo,0.00,stock,perecedero,inventariable);

              }

            } else if (exento == 1){

              if(tipo_precio == 1)
              {
                agregar_detalle(idproducto,producto,datos,precio_venta,precio_venta1,precio_venta2,precio_venta3,exento,stock,perecedero,inventariable);

              } else if (tipo_precio == 0){
                agregar_detalle(idproducto,producto,datos,precio_venta_mayoreo,exento,stock,perecedero,inventariable);

              }

            }

        }

        $(this).val("");
        return false;
    },
    open: function(event, ui) {
             $(".ui-autocomplete").css("z-index", 1000);
    },

    _renderItem: function( ul, item ) {

    var re = new RegExp( "(" + this.term + ")", "gi" ),
        cls = this.options.highlightClass,
        template = "<span class='" + cls + "'>$1</span>",
        label = item.label.replace( re, template ),
        $li = $( "<li/>" ).appendTo( ul );
           
    $( "<a/>" ).attr( "href", "#" )
               .html( label )
               .appendTo( $li );
            
    return $li;
            
}

})


.autocomplete("instance")._renderItem = function(ul, item) {

    return $("<li>").append("<span class='text-semibold'>" + item.label + '</span>' + "<br>" + '<span class="text-muted text-size-small">' + item.datos + '</span>').appendTo(ul);
}

}



// Evento que selecciona la fila y la elimina de la tabla
$(document).on("click", ".Delete", function () {
    var parent = $(this).closest('tr');
    var dropdown = parent.find('#ddl-precio_venta'); // Encuentra el dropdown dentro de la fila
    
    if (dropdown.length > 0) {
        dropdown.val(null); // Resetea el valor del dropdown a null
    }
    
    console.log("Botón de eliminar clickeado");
    
    parent.remove(); // Elimina la fila
    totales(); // Llama a la función totales después de eliminar la fila
});


$(document).on("focusout","#tblcant, #tbldesc",function(){
    totales();
})


$("#btncancelar").click(function(){

        swal({
            title: "¿Está seguro que desea cancelar la Cotizacion?",
            text: "Se eliminaran todos los datos que ya ingreso!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: "#EF5350",
            confirmButtonText: "Si, cancelar",
            cancelButtonText: "No, deseo continuar",
            closeOnConfirm: false,
            closeOnCancel: false
        },
        function(isConfirm){
            if (isConfirm) {
                swal({
                    title: "Cancelado!",
                    text: "Su proceso fue cancelado con exito.",
                    confirmButtonColor: "#66BB6A",
                    type: "success"
                },
                function() {
                    setTimeout(function() {
                        location.reload();
                    }, 1200);
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
});


//---------************* Totales

function totales(esCambioDropdown = false) {
    if ($('#tbldetalle > tbody > tr:visible').length === 0) {
        $("#btncancelar").hide();
        $("#btnguardar").hide();
        $("#totales_foot").hide();
        $('#txtMonto').prop("disabled", true);
        return;
    }

    var total_sumas = 0;
    var total_exentos = 0;
    var total_iva = 0;
    var subtotal = 0;
    var total_descuentos = 0;
    var iva_retenido = 0;
    var iva = 0;
    //var imp = 0;

    $.getJSON('web/ajax/ajxparametro.php?criterio=moneda', function(data) {
        $.each(data, function(key, val) {
            var moneda = val.CurrencyISO + ' ' + val.Symbol;

            $.getJSON('web/ajax/ajxparametro.php?criterio=iva', function(data) {
                $.each(data, function(key, val) {
                    var valor_iva = val.porcentaje_iva;
                    var monto_retencion = val.monto_retencion;
                    var porcentaje_retencion = val.porcentaje_retencion;

                    iva = valor_iva / 100;
                    var porc_rete = porcentaje_retencion / 100;

                    // Recorre cada fila de la tabla
                    $("#tbldetalle tbody tr").each(function(index) {
                        var fila = $(this);

                        var precioSeleccionado = fila.find('select[class="ddl-precio_venta"]').val();
                        var dropdown = fila.find('.ddl-precio_venta');

                        if (dropdown.length) {
                            console.log("Fila " + (index + 1) + " - valor del dropdown:", dropdown.val());

                            precioSeleccionado = parseFloat(dropdown.val()); // Obtiene el valor actualmente seleccionado
                            if (isNaN(precioSeleccionado)) {
                                console.error("El valor del dropdown es inválido en la fila " + (index + 1));
                                return;
                            }
                        } else {
                            console.error("No se encontró el dropdown en la fila " + (index + 1));
                            return;
                        }

                        // Realiza los cálculos con el precio seleccionado
                        var cantidad = parseFloat(fila.find("#tblcant").val()) || 0;
                        var exentos = parseFloat(fila.find(".exento").text()) || 0;
                        var descuentos = (parseFloat(fila.find("#tbldesc").val()) * cantidad) || 0;
                        var sumas = cantidad * precioSeleccionado - descuentos;

                        // Depuración: mostrar los valores calculados
                        console.log("Fila " + (index + 1) + " - cantidad:", cantidad, "precio seleccionado:", precioSeleccionado, "sumas:", sumas);

                        // Actualiza las celdas correspondientes
                        fila.find(".precio_venta_nuevo").text(sumas.toFixed(2));

                        subtotal += sumas;
                        total_sumas = subtotal;

                        total_exentos += exentos;

                        total_descuentos += descuentos;

                        if (exentos > 0) {
                          imp = sumas * iva;
                        }

                        if (total_exentos > 0) {
                          total_exentos = imp;
                        } else {
                          total_iva += sumas * iva;
                          total_exentos = 0;
                        }
                        
                        if (total_sumas >= monto_retencion) {
                            iva_retenido = total_sumas * porc_rete;
                        }
                    });

                    // Actualiza los campos totales en pantalla
                    $("#sumas").html(total_sumas.toFixed(2));
                    $("#iva").html(total_iva.toFixed(2));
                    $("#subtotal").html(subtotal.toFixed(2));
                    $("#ivaretenido").html(iva_retenido.toFixed(2));
                    $("#exentas").html(total_exentos.toFixed(2));
                    $("#descuentos").html(total_descuentos.toFixed(2));
                    $("#total").html((subtotal + total_iva - iva_retenido).toFixed(2));

                    $("#big_total").html(moneda+' '+ $.number((subtotal + total_iva - iva_retenido), 2 ));

                    // Mostrar/ocultar botones según haya filas visibles o no
                    if ($('#tbldetalle > tbody > tr:visible').length > 0) {
                        $("#btncancelar").show();
                        $("#btnguardar").show();
                        $("#totales_foot").show();
                        $('#txtMonto').prop("disabled", false);
                    } else {
                        $("#btncancelar").hide();
                        $("#totales_foot").hide();
                        $("#btnguardar").hide();
                        $('#txtMonto').prop("disabled", true);
                    }
                });
            });
        });
    });
}


//---------************* Totales

//---------************* Enviar datos y guardar compra



function enviar_data(){

  var i=0;
  var StringDatos="";
  var proceso = 'Generar';
  var pagado = $('#chkPagado').is(':checked') ? 1 : 2;
  var comprobante = $("#cbCompro").val();
  var idcliente = $("#cbCliente").val();
  var a_nombre = $("#cbCliente option:selected").text();
  var tipo_entrega = $('#cbEntrega').val();
  var sumas = $("#sumas").text();
  var iva = $("#iva").text();
  var exento = $("#exentas").text();
  var retenido = $("#ivaretenido").text();
  var descuentos = $("#descuentos").text();
  var cambio = $("#txtCambio").val();
  var total = $("#total").text();

  var efectivo = $("#txtMonto").val();
  var pago_tarjeta = $("#txtMontoTar").val();
  var numero_tarjeta = $("#txtNoTarjeta").val();
  var tarjeta_habiente = $("#txtHabiente").val();



  var cantidad = 0;
  var precio_unitario = 0;
  var ventas_nosujetas = 0;
  var exentos = 0;
  var importe = 0;
  var descuento = 0;
  var fecha_vence = "";
  var disponible = "";



    $("#tbldetalle tbody tr").each(function (index)
        {
            var campo1, campo2, campo3, campo4, campo5, campo6, campo7, campo8;
            $(this).children("td").each(function (index2)
            {
                switch (index2)
                {

                    case 0:  campo0 = $(this).text();
                             break;

                    case 1:  campo1 = $(this).text();
                             break;

                    case 2:  campo2 = $(this).text();
                             disponible = campo2;
                             break;

                    case 3:  campo3 = $(this).find("#tblcant").val();
                             /*cantidad = parseFloat(campo3);*/
                              cantidad = (campo3);
                             break;

                    case 4:  campo4 = $(this).text();
                             precio_unitario  = parseFloat(campo4);
                             break;

                    case 5: campo5 = $(this).text();
                            exentos = parseFloat(campo5);
                            break;

                    case 6:  campo6 = $(this).find("#tbldesc").val();
                             descuento = parseFloat(campo6);
                             break;

                    case 7:  campo7 = campo3 * campo4;
                             importe = parseFloat(campo7);
                             $(this).text(campo7.toFixed(2));
                             break;

                }
              //  $(this).css("background-color", "#ECF8E0");
            })

        if(campo0!=""|| campo0==undefined || isNaN(campo0)==false && cantidad > 0){
        StringDatos+=campo0+"|"+cantidad+"|"+precio_unitario+"|"+exentos+"|"+descuento+"|"+disponible+"|"+importe+"#";
        i=i+1;
        }

     })



        var dataString='&stringdatos='+StringDatos+'&cuantos='+i;
        dataString+='&tipo_entrega='+tipo_entrega+'&idcliente='+idcliente+'&sumas='+sumas+'&iva='+iva+'&a_nombre='+a_nombre;
        dataString+='&retenido='+retenido+'&exento='+exento+'&descuento='+descuentos+'&total='+total+'&pagado='+pagado+'&proceso='+proceso;

        //console.log(dataString);

      if(total > 0.00){

            $.ajax({

            type:'POST',
            url:'web/ajax/ajxcotizacion.php',
            data: dataString,
            cache: false,
            dataType: 'json',
            success: function(data){

              if(data=="Validado"){

                $("#btnguardar").hide();
                $("#btncancelar").hide();
                $('#modal_iconified_cash').modal('toggle');
                swal("Espere un momento..");
				
				// SweetAlert para el rol de cajero
                            swal({
                                title: "Venta enviada a caja",
                                text: "Su cliente lo puede solicitar",
                                imageUrl: "web/assets/images/receipt.png",
                                showCancelButton: true,
                                cancelButtonColor: "#EF5350",
                                confirmButtonColor: "#43ABDB",
                                closeOnConfirm: false,
                                closeOnCancel: false,
                            },
                            function(isConfirm){
                              if (isConfirm) {
								 window.open('reportes/Cotizacion.php?cotizacion=""',
								'win2',
								'status=yes,toolbar=yes,scrollbars=yes,titlebar=yes,menubar=yes,'+
								'resizable=yes,width=800,height=1000  ,directories=no,location=no'+
								'fullscreen=yes');
                                location.reload();
                              }

                            });
                 

              } else {

                swal('Lo sentimos, no pudimos registrar tu informacion!', "Intentalo nuevamente", "error");
              }

            },error: function() {

               swal("Ups! Ocurrio un error","Algo salio mal al procesar tu peticion","error");
          }


        });


        } else {

           swal("Imposible","No se puede registrar una compra con valor 0.00","warning");

        }
}
