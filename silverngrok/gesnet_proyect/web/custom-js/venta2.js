// Función para agregar detalles de los productos seleccionados
function agregar_detalle(idproducto, producto, especificacion, precio_venta, precio_venta1, precio_venta2, precio_venta3, exento, stock, perecedero, inventariable) {
    var tr_add = "";
    var id_previo = [];
    var filas = 0;

    // Verificar las filas previas y almacenar los ID de productos existentes
    $("#tbldetalle tr").each(function(index) {
        if (index > 0) {
            var campo0;
            $(this).children("td").each(function(index2) {
                if (index2 === 0) {
                    campo0 = $(this).text();
                    if (campo0 !== undefined || campo0 !== '') {
                        id_previo.push(campo0);
                    }
                }
            });
            filas += 1;
        }
    });

    // Lógica para crear el HTML dinámico de una nueva fila de producto
    tr_add += '<tr>';
    tr_add += '<td align="center">' + idproducto + '</td>';
    tr_add += '<td><h8 class="no-margin">' + producto + '</h8><br><span class="text-muted">' + especificacion + '</span></td>';
    tr_add += '<td width="5%"><input type="text" id="tblcant" name="tblcant" value="1" class="touchspin" style="width:70px;"></td>';
    tr_add += '<td align="center">';
    tr_add += '<select id="ddl-precio-venta" name="ddl-precio" class="ddl-precio">';
    tr_add += '<option value="' + precio_venta + '">' + precio_venta + '</option>';
    tr_add += '<option value="' + precio_venta1 + '">' + precio_venta1 + '</option>';
    tr_add += '<option value="' + precio_venta2 + '">' + precio_venta2 + '</option>';
    tr_add += '<option value="' + precio_venta3 + '">' + precio_venta3 + '</option>';
    tr_add += '</select>';
    tr_add += '</td>';
    tr_add += '<td align="center">' + exento + '</td>';
    tr_add += '<td width="5%"><input type="text" id="tbldesc" name="tbldesc" value="0.00" class="touchspin" style="width:70px;"></td>';
    tr_add += '<td id="precio_venta_nuevo" align="center">' + precio_venta + '</td>';
    tr_add += '<td align="center" class="Delete"><button type="button" class="btn btn-link btn-xs"><i class="icon-trash-alt"></i></button></td>';
    tr_add += '</tr>';

    var existe = false;
    var posicion_fila = 0;

    // Verificar si el producto ya existe en la tabla
    $.each(id_previo, function(i, id_prod_ant) {
        if (idproducto == id_prod_ant) {
            existe = true;
            posicion_fila = i;
        }
    });

    if (!existe) {
        $("#tbldetalle").append(tr_add);

        // Asignar el evento 'change' al nuevo dropdown de la fila creada
        var dropdowns = document.querySelectorAll('.ddl-precio-venta');
        dropdowns.forEach(function(dropdown) {
            dropdown.addEventListener('change', function() {
                var seleccionado = this.value;
                var fila = this.closest('tr'); // Obtener la fila actual

                // Actualizar la celda del precio en la fila
                var celdaPrecio = fila.querySelector('#precio_venta_nuevo');
                if (celdaPrecio) {
                    celdaPrecio.textContent = seleccionado; // Cambiar el valor directamente en la fila
                }

                // Llamar a la función para actualizar los totales
                actualizarDatosPantalla(seleccionado);
            });
        });

        // Inicializar elementos dinámicos como TouchSpin y Select2
        $('.select-size-xs').select2();
        $("input[name='tblcant'], input[name='tbldesc']").TouchSpin().on('touchspin.on.startspin', function() {
            totales();
        });

        noty({
            force: true,
            text: 'Producto agregado!',
            type: 'information',
            layout: 'top',
            timeout: 500,
        });

        totales();

    } else {
        posicion_fila += 1;
        setRowCant(posicion_fila);

        noty({
            force: true,
            text: 'Producto agregado!',
            type: 'information',
            layout: 'top',
            timeout: 500,
        });
    }
}

// Función para actualizar los datos en pantalla
function actualizarDatosPantalla(precio_venta) {
    console.log("El valor de precio_venta ha cambiado a: " + precio_venta);
    totales();
}

// Función para manejar el evento de eliminación de una fila
$(document).on("click", ".Delete", function() {
    var parent = $(this).closest('tr');
    var dropdown = parent.find('#ddl-precio-venta');

    if (dropdown.length > 0) {
        dropdown.val(null); // Resetea el valor del dropdown
    }

    console.log("Botón de eliminar clickeado");

    parent.remove(); // Elimina la fila
    totales(); // Actualiza los totales después de eliminar la fila
});

// Función que maneja los totales
function totales() {
    // Lógica de totales
}
