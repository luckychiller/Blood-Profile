<!DOCTYPE html>
<html lang="en">
<head>
  <!-- basic -->
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- mobile metas -->
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="viewport" content="initial-scale=1, maximum-scale=1">
  <!-- site metas -->
  <title>Attention and Focus Task</title>
  <meta name="keywords" content="">
  <meta name="description" content="">
  <meta name="author" content="">
  <!-- bootstrap css -->
  <link rel="stylesheet" type="text/css" href="css/bootstrap.min.css">
  <!-- style css -->
  <link rel="stylesheet" type="text/css" href="css/style.css">
  <!-- Responsive-->
  <link rel="stylesheet" href="css/responsive.css">
  <!-- fevicon -->
  <link rel="icon" href="images/fevicon.png" type="image/gif" />
  <!-- Scrollbar Custom CSS -->
  <link rel="stylesheet" href="css/jquery.mCustomScrollbar.min.css">
  <!-- Tweaks for older IEs-->
  <link rel="stylesheet" href="https://netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.css">
  <!-- fonts -->
  <link href="https://fonts.googleapis.com/css?family=Great+Vibes|Open+Sans:400,700&display=swap&subset=latin-ext" rel="stylesheet">
  <!-- owl stylesheets -->
  <link rel="stylesheet" href="css/owl.carousel.min.css">
  <link rel="stylesheet" href="css/owl.theme.default.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/jquery.fancybox.min.css" media="screen">
  <link href="https://unpkg.com/gijgo@1.9.13/css/gijgo.min.css" rel="stylesheet" type="text/css" />


  <style>
    .grid {
      display: grid;
      grid-template-columns: repeat(10, 50px);
      grid-gap: 5px;
    }
    .item {
      width: 50px;
      height: 50px;
      display: flex;
      justify-content: center;
      align-items: center;
      background-color: lightgray;
      cursor: pointer;
    }
    .target {
      background-color: yellow;
    }
    #timer {
      font-size: 24px;
      margin-bottom: 20px;
    }
  </style>



</head>
<body>
<!-- banner section start -->
<div class="banner_section layout_padding">
  <div id="carouselExampleIndicators" data-ride="carousel">
    <div class="carousel-inner">
      <div class="carousel-item active">
        <div class="container">
          <div class="row">
            <div class="col-sm-6">
              <h1 class="banner_taital">Focus <br>Check </h1>
              <p class="banner_text">Welcome to our Attention and Focus Assessment Tool. This interactive task is designed to evaluate your attention span and ability to filter out distractions. You will be presented with a series of items on the screen and asked to find and click on specific target items among various distractors.
                <br>We will measure the time taken to find each target and the number of errors made. This assessment provides valuable insights into your cognitive functions, helping to detect potential attention issues such as ADHD or cognitive fatigue.
                <br>Your performance data will be analyzed to generate a personalized report, offering feedback and recommendations based on your results.
                <br><br><br>
              </p>
            </div>
            <div class="col-sm-6">
              <div class="banner_img"><img src="images/focusBanner.png"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<!-- banner section end -->




<div class="customer_section layout_padding">
  <div class="container">
    <div class="row">
      <div class="col-sm-12">
        <h1>Find the Yellow Squares as fast as you can!!...</h1>
        <div id="timer">Time left: 30 seconds</div>
        <div class="grid" id="grid"></div>
        <button onclick="startTask()">Start Task</button>
      </div>
    </div>
  </div>
</div>


<script>
  const grid = document.getElementById('grid');
  const timerDisplay = document.getElementById('timer');
  let startTime, endTime, timer;
  let errors = 0;
  let targetsFound = 0;
  const targetCount = 5;
  const taskDuration = 30; // Task duration in seconds

  function createGrid() {
    for (let i = 0; i < 100; i++) {
      const div = document.createElement('div');
      div.classList.add('item');
      if (Math.random() < 0.1) { // 10% chance to be a target
        div.classList.add('target');
      }
      div.addEventListener('click', handleClick);
      grid.appendChild(div);
    }
  }

  function handleClick(event) {
    if (!startTime) return;
    if (event.target.classList.contains('target')) {
      event.target.style.backgroundColor = 'green';
      targetsFound++;
      if (targetsFound === targetCount) {
        endTask();
      }
    } else {
      errors++;
      event.target.style.backgroundColor = 'red';
    }
  }

  function startTask() {
    startTime = new Date().getTime();
    errors = 0;
    targetsFound = 0;
    const items = document.querySelectorAll('.item');
    items.forEach(item => item.style.backgroundColor = 'lightgray');
    timerDisplay.textContent = `Time left: ${taskDuration} seconds`;
    startTimer();
  }

  function startTimer() {
    let timeLeft = taskDuration;
    timer = setInterval(() => {
      timeLeft--;
      timerDisplay.textContent = `Time left: ${timeLeft} seconds`;
      if (timeLeft <= 0) {
        endTask();
      }
    }, 1000);
  }

  function endTask() {
    clearInterval(timer);
    endTime = new Date().getTime();
    const timeTaken = (endTime - startTime) / 1000;
    alert(`Task completed in ${timeTaken} seconds with ${errors} errors.`);
    sendResults(timeTaken, errors);
  }

  function sendResults(time, errors) {
    fetch('/HelloServlet', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ time, errors })
    });
  }

  createGrid();
</script>













<!-- customer section start -->
<div class="customer_section layout_padding">
  <div class="container">
    <div class="row">
      <div class="col-sm-12">
        <h1 class="customer_taital">Developers</h1>
      </div>
    </div>
    <div id="main_slider" class="carousel slide" data-ride="carousel">
      <div class="carousel-inner">
        <div class="carousel-item active">
          <div class="client_section_2">
            <div class="client_main">
              <div class="client_left">
                <div class="client_img"><img src="images/shadid.jpeg"></div>
              </div>
              <div class="client_right">
                <h3 class="name_text">Abuhena Shadid</h3>
                <p class="dolor_text">consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation  eu </p>
              </div>
            </div>
          </div>
        </div>
        <div class="carousel-item">
          <div class="client_section_2">
            <div class="client_main">
              <div class="client_left">
                <div class="client_img"><img src="images/soikey.jpg"></div>
              </div>
              <div class="client_right">
                <h3 class="name_text">Mahajabin Tabassum</h3>
                <p class="dolor_text">consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation  eu </p>
              </div>
            </div>
          </div>
        </div>
        <div class="carousel-item">
          <div class="client_section_2">
            <div class="client_main">
              <div class="client_left">
                <div class="client_img"><img src="images/lutufi.jpeg"></div>
              </div>
              <div class="client_right">
                <h3 class="name_text">Wasswa Lutufi Sebbanja</h3>
                <p class="dolor_text">consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation  eu </p>
              </div>
            </div>
          </div>
        </div>
      </div>
      <a class="carousel-control-prev" href="#main_slider" role="button" data-slide="prev">
        <i class="fa fa-angle-left"></i>
      </a>
      <a class="carousel-control-next" href="#main_slider" role="button" data-slide="next">
        <i class="fa fa-angle-right"></i>
      </a>
    </div>
  </div>
</div>
<!-- customer section end -->
<!-- contact section start -->
<div class="contact_section layout_padding">
  <div class="container">
    <div class="row">
      <div class="col-sm-12">
        <h1 class="customer_taital">Find Us</h1>
      </div>
    </div>
  </div>
  <div class="map_main">
    <div class="map-responsive">
      <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d14586.168628099751!2d90.3842619!3d23.94126145!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3755c4abf8334fb1%3A0xbb003124c3dedc91!2sIslamic%20University%20of%20Technology!5e0!3m2!1sen!2sbd!4v1712284567905!5m2!1sen!2sbd" width="1400" height="300" style="border:0;" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>
    </div>
  </div>
</div>
<!-- contact section end -->
<!-- footer section start -->
<div class="footer_section">
  <div class="container">
    <div class="social_icon">
      <ul>
        <li>
          <a href="#"><i class="fa fa-facebook" aria-hidden="true"></i></a>
        </li>
        <li>
          <a href="#"><i class="fa fa-twitter" aria-hidden="true"></i></a>
        </li>
        <li>
          <a href="#"><i class="fa fa-linkedin" aria-hidden="true"></i></a>
        </li>
        <li>
          <a href="#"><i class="fa fa-instagram" aria-hidden="true"></i></a>
        </li>
      </ul>
    </div>
  </div>
</div>
<!-- footer section end -->
<!-- copyright section start -->
<div class="copyright_section">
  <div class="container">
    <p class="copyright_text">2024 All Rights Reserved by CSE4622.</p>
  </div>
</div>
<!-- copyright section end -->
<!-- Javascript files-->
<script src="js/jquery.min.js"></script>
<script src="js/popper.min.js"></script>
<script src="js/bootstrap.bundle.min.js"></script>
<script src="js/jquery-3.0.0.min.js"></script>
<script src="js/plugin.js"></script>
<!-- sidebar -->
<script src="js/jquery.mCustomScrollbar.concat.min.js"></script>
<script src="js/custom.js"></script>
<!-- javascript -->
<script src="js/owl.carousel.js"></script>
<script src="https:cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/jquery.fancybox.min.js"></script>
<script src="https://unpkg.com/gijgo@1.9.13/js/gijgo.min.js" type="text/javascript"></script>
<script>
  function openNav() {
    document.getElementById("mySidenav").style.width = "100%";
  }

  function closeNav() {
    document.getElementById("mySidenav").style.width = "0";
  }
</script>
</body>
</html>