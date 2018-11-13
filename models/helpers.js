module.exports = {
  assert: function(value, true_val = "Assertion true.", 
    false_val = "Assertion false.") {
    console.log(value ? true_val : false_val)
  },

  report: function(msg) {
    console.log(msg);
  }
}