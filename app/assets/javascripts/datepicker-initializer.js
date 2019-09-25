function initializeDatepicker(datepickerSelector = '.datepicker') {
  let opts = {
    language: "es",
    dateFormat: "dd/mm/yyyy",
    todayHighlight: true,
    autoClose: true,
    startView: 2,
  }
  $(datepickerSelector)
    .datepicker(opts)
    .on('changeDate', (e) => $(e.target).datepicker("hide"))
}
