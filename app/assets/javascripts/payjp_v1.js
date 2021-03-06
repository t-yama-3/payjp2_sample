document.addEventListener("turbolinks:load", function() {
  if (document.getElementById('create_btn') == null) { return; }  // 対象外のページの場合はreturn
  Payjp.setPublicKey('pk_test_6a23cbc185cf21b00610bbb5');
  document.getElementById("create_btn").addEventListener("click", function(e) {
    e.preventDefault();
    let card = {
      number: document.getElementById('number').value,
      cvc: document.getElementById('cvc').value,
      exp_month: document.getElementById('exp_month').value,
      exp_year: document.getElementById('exp_year').value
    };
    Payjp.createToken(card, function(status, response) {
      if (status == 200) {
        document.getElementById('payjp_token').setAttribute("value", response.id);  // payjpとの通信で取得したトークンをフォームに格納
        document.getElementById('send_token').submit();  // トークンをアプリケーションのサーバに送信
      } else {
        alert('カード情報の認証ができませんでした');
      }
    });
  }, false);
});
