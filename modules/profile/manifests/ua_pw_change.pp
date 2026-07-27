#modules/profile/manifests/ua_pw_change.pp
class profile::ua_pw_change {
  user { 'bit':
    ensure   => present,
    password => '$6$AcZUsaAZcC6tXgBK$E0WWvOG.YOeIwyVhBhOv.8gq/YuCIdoIjzm62uKmXFJ4TUKjsdHHsOJU3MBQquSu2xTuqm4EYjsTnwhUKQ2Ch.',
  } #  bitX100
}
