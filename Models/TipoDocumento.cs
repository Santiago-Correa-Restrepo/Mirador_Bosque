using System;
using System.Collections.Generic;

namespace NovenaPrueba.Models;

public partial class TipoDocumento
{
    public int IdTipoDocumento { get; set; }

    public string NomTipoDcumento { get; set; } = null!;

    public virtual ICollection<Cliente> Clientes { get; set; } = new List<Cliente>();
}
