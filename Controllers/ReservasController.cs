using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using NovenaPrueba.Models;

namespace NovenaPrueba.Controllers
{
    public class ReservasController : Controller
    {
        private readonly BdMiradorrContext _context;

        public ReservasController(BdMiradorrContext context)
        {
            _context = context;
        }

        // GET: Reservas
        public async Task<IActionResult> Index()
        {
            var bdMiradorrContext = _context.Reservas.Include(r => r.IdEstadoReservaNavigation).Include(r => r.MetodoPagoNavigation).Include(r => r.NroDocumentoClienteNavigation).Include(r => r.NroDocumentoUsuarioNavigation);
            return View(await bdMiradorrContext.ToListAsync());
        }

        // GET: Reservas/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var reserva = await _context.Reservas
                .Include(r => r.IdEstadoReservaNavigation)
                .Include(r => r.MetodoPagoNavigation)
                .Include(r => r.NroDocumentoClienteNavigation)
                .Include(r => r.NroDocumentoUsuarioNavigation)
                .FirstOrDefaultAsync(m => m.IdReserva == id);
            if (reserva == null)
            {
                return NotFound();
            }

            return View(reserva);
        }

        // GET: Reservas/Create
        public IActionResult Create()
        {
            ViewData["IdEstadoReserva"] = new SelectList(_context.EstadosReservas, "IdEstadoReserva", "NombreEstadoReserva");
            ViewData["MetodoPago"] = new SelectList(_context.MetodoPagos, "IdMetodoPago", "NomMetodoPago");
          
            return View();
        }

        // Acción para obtener los servicios
        [HttpGet]
        public JsonResult ObtenerServicios()
        {
            var servicios = _context.Servicios.Select(s => new
            {
                id = s.IdServicio,
                nombreservicio = s.NomServicio,
                costo = s.Precio
            }).ToList();

            return Json(new { servicios });
        }

        public JsonResult ObtenerDetallesServicio(int id)
        {
            var servicio = _context.Servicios
                .Where(s => s.IdServicio == id)
                .Select(s => new
                {
                    nombres = s.NomServicio,
                    precio = s.Precio,
                    descripcion = s.Descripcion
                })
                .FirstOrDefault();

            if (servicio != null)
            {
                return Json(new { success = true, servicio });
            }
            else
            {
                return Json(new { success = false });
            }
        }

        [HttpGet]
        // Acción para obtener los detalles del paquete seleccionado
        public JsonResult ObtenerPaquetes()
        {
            var paquetes = _context.Paquetes.Select(p => new
            {
                id = p.IdPaquete,
                nombrepaquete = p.NomPaquete
            }).ToList();

            return Json(new { paquetes });
        }

        // Acción para obtener los detalles del paquete seleccionado
        public JsonResult ObtenerDetallesPaquete(int id)
        {
            var paquete = _context.Paquetes
                .Where(p => p.IdPaquete == id)
                .Select(p => new
                {
                    p.Precio,
                    p.IdHabitacionNavigation.Nombre,
                    p.Descripcion,
                    Servicios = p.DetalleReservaPaquetes
                        .Select(dp => new
                        {
                            dp.IdPaquete,
                            dp.IdReserva,
                            dp.Precio,
                            dp.IdPaqueteNavigation.IdHabitacionNavigation.Nombre
                        }).ToList()
                }).FirstOrDefault();

            if (paquete != null)
            {
                return Json(new { success = true, paquete });
            }
            else
            {
                return Json(new { success = false });
            }
        }

        public async Task<JsonResult> ObtenerClientePorDocumento(int documento)
        {
            var cliente = await _context.Clientes
                .Where(c => c.NroDocumento == documento)
                .Select(c => new
                {
                    c.Nombres,
                    c.Apellidos,
                    c.Correo,
                    c.Celular,
                    TipoDocumento = c.IdTipoDocumentoNavigation.NomTipoDcumento // Ajusta según tu modelo
                })
                .FirstOrDefaultAsync();

            if (cliente == null)
            {
                return Json(new { existe = false, mensaje = "Cliente no encontrado." });
            }

            return Json(new { existe = true, cliente });
        }

        [HttpPost]
        public ActionResult CrearReserva(Reserva model,int clienteId, string paqueteSeleccionados, string serviciosSeleccionados, decimal descuento)
        {
            try
            {
                // Deserialización de paquetes y servicios seleccionados
                var paquetesSeleccionados = JsonConvert.DeserializeObject<List<PaqueteSeleccionado>>(paqueteSeleccionados);
                var servicioSeleccionados = JsonConvert.DeserializeObject<List<ServicioSeleccionado>>(serviciosSeleccionados);

                // Primero, obtiene los datos del cliente
                var cliente = _context.Clientes.FirstOrDefault(c => c.NroDocumento == clienteId);
                if (cliente == null)
                {
                    return Json(new { success = false, message = "Cliente no encontrado" });
                }

                // Crear la reserva en la base de datos
                var reserva = new Reserva
                {
                    NroDocumentoCliente = cliente.NroDocumento,
                    FechaReserva = DateTime.Now,
                    FechaInicio = model.FechaInicio,
                    FechaFinalizacion = model.FechaFinalizacion,
                    SubTotal = 0,
                    Iva = 0,
                    Descuento = model.Descuento,
                    MontoTotal = 0,
                    NroPersonas = model.NroPersonas,
                    IdEstadoReserva = model.IdEstadoReserva, // Establece el estado de la reserva aquí
                    MetodoPago = model.MetodoPago  // Establece el método de pago aquí
                };

                _context.Reservas.Add(reserva);
                _context.SaveChanges(); // Guarda la reserva antes de agregar los detalles

                decimal subtotal = 0;
                decimal ivaPercentage = 0.19M;

                // Relacionar los paquetes seleccionados con la reserva
                foreach (var paqueteSeleccionado in paquetesSeleccionados)
                {
                    var paquete = _context.Paquetes.FirstOrDefault(p => p.IdPaquete == paqueteSeleccionado.IdPaquete);
                    if (paquete != null)
                    {
                        _context.DetalleReservaPaquetes.Add(new DetalleReservaPaquete
                        {
                            IdReserva = reserva.IdReserva,
                            IdPaquete = paquete.IdPaquete
                        });
                        _context.SaveChanges();
                        subtotal += paquete.Precio;
                    }
                }

                // Procesar cada servicio seleccionado
                foreach (var servicioId in serviciosSeleccionados)
                {
                    var servicio = _context.Servicios.FirstOrDefault(s => s.IdServicio == servicioId);
                    if (servicio != null)
                    {
                        _context.DetalleReservaServicios.Add(new DetalleReservaServicio
                        {
                            IdReserva = reserva.IdReserva,
                            IdServicio = servicio.IdServicio,
                            Cantidad = 1 // Puedes ajustar la cantidad si es necesario
                        });

                        subtotal += servicio.Precio;
                        _context.SaveChanges();
                    }
                }

                decimal iva = subtotal * ivaPercentage;
                decimal montoTotalConIva = subtotal + iva;
                decimal montoTotalFinal = montoTotalConIva - (montoTotalConIva * (descuento / 100));

                reserva.SubTotal = (double)subtotal;
                reserva.Iva = (double)iva;
                reserva.MontoTotal = (double)montoTotalFinal;

                _context.SaveChanges(); // Guarda los cambios en la reserva después de calcular el total

                return Json(new { success = true, message = "Reserva creada exitosamente", idReserva = reserva.IdReserva });
            }
            catch (Exception ex)
            {
                // Manejo de la excepción: devuelve un mensaje de error
                return Json(new { success = false, message = "Ocurrió un error al crear la reserva.", error = ex.Message });
            }
        }

        // POST: Reservas/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.


        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("IdReserva,NroDocumentoCliente,NroDocumentoUsuario,FechaReserva,FechaInicio,FechaFinalizacion,SubTotal,Descuento,Iva,MontoTotal,MetodoPago,NroPersonas,IdEstadoReserva")] Reserva reserva)
        {
            if (id != reserva.IdReserva)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(reserva);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!ReservaExists(reserva.IdReserva))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction(nameof(Index));
            }
            ViewData["IdEstadoReserva"] = new SelectList(_context.EstadosReservas, "IdEstadoReserva", "IdEstadoReserva", reserva.IdEstadoReserva);
            ViewData["MetodoPago"] = new SelectList(_context.MetodoPagos, "IdMetodoPago", "IdMetodoPago", reserva.MetodoPago);
            ViewData["NroDocumentoCliente"] = new SelectList(_context.Clientes, "NroDocumento", "NroDocumento", reserva.NroDocumentoCliente);
            ViewData["NroDocumentoUsuario"] = new SelectList(_context.Usuarios, "NroDocumento", "NroDocumento", reserva.NroDocumentoUsuario);
            return View(reserva);
        }

        // GET: Reservas/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var reserva = await _context.Reservas
                .Include(r => r.IdEstadoReservaNavigation)
                .Include(r => r.MetodoPagoNavigation)
                .Include(r => r.NroDocumentoClienteNavigation)
                .Include(r => r.NroDocumentoUsuarioNavigation)
                .FirstOrDefaultAsync(m => m.IdReserva == id);
            if (reserva == null)
            {
                return NotFound();
            }

            return View(reserva);
        }

        // POST: Reservas/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var reserva = await _context.Reservas.FindAsync(id);
            if (reserva != null)
            {
                _context.Reservas.Remove(reserva);
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool ReservaExists(int id)
        {
            return _context.Reservas.Any(e => e.IdReserva == id);
        }
    }
}
