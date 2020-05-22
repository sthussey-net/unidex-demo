using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

using Unidex.Model;

namespace Unidex.Controllers
{
    [ApiController]
    [Route("/characters")]
    public class CharacterController : ControllerBase
    {
        private readonly ILogger<CharacterController> _logger;

        public CharacterController(ILogger<CharacterController> logger) {
            _logger = logger;
        }

        [HttpGet]
        [Produces("application/json")]
        public ActionResult Get() {
            return Ok(new Character());
        }

        [HttpPost]
        [Consumes("application/json")]
        [Produces("application/json")]
        public ActionResult Create(Character character) {
            return Ok(character);
        }
    }

    [ApiController]
    [Route("/locations")]
    public class LocationController : ControllerBase
    {
        private readonly ILogger<LocationController> _logger;

        public LocationController(ILogger<LocationController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        [Produces("application/json")]
        public ActionResult Get(){
            return Ok(new Location("Mainstreet, USA"));
        }

        [HttpPost]
        [Consumes("application/json")]
        [Produces("application/json")]
        public ActionResult Create(Location loc){
            return Ok(loc);
        }
    }
}
