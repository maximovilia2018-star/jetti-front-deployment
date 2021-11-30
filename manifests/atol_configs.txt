# class atol_configs {
#
#   #   file { '/home/bit/.atol/drivers10/fptr10_log.properties':
#   #       ensure  => 'present',
#   #       owner => "bit",
#   #       group => "bit",
#   #       replace => 'yes',
#   #       content => 'log4cpp.rootCategory=ERROR, file
#   # log4cpp.category.FiscalPrinter=ERROR, file
#   # log4cpp.category.Transport=ERROR, file
#   # log4cpp.category.EthernetOverTransport=ERROR, ofd
#   # log4cpp.category.DeviceDebug=ERROR, device_debug
#   # log4cpp.category.1C=ERROR, file1C
#   # log4cpp.category.Web=ERROR, file
#   #
#   # log4cpp.appender.console=ConsoleAppender
#   # log4cpp.appender.console.layout=PatternLayout
#   # log4cpp.appender.console.layout.ConversionPattern=%d{%Y.%m.%d %H:%M:%S.%l} T:%t %-5p [%c] %m%n
#   #
#   # log4cpp.appender.file=DailyRollingFileAppender
#   # log4cpp.appender.file.fileName=/home/bit/.atol/drivers10/logs/fptr10.log
#   # log4cpp.appender.file.maxDaysKeep=2
#   # log4cpp.appender.file.layout=PatternLayout
#   # log4cpp.appender.file.layout.ConversionPattern=%d{%Y.%m.%d %H:%M:%S.%l} T:%t %-5p [%c] %m%n
#   #
#   # log4cpp.appender.ofd=DailyRollingFileAppender
#   # log4cpp.appender.ofd.fileName=/home/bit/.atol/drivers10/logs/ofd.log
#   # log4cpp.appender.ofd.maxDaysKeep=2
#   # log4cpp.appender.ofd.layout=PatternLayout
#   # log4cpp.appender.ofd.layout.ConversionPattern=%d{%Y.%m.%d %H:%M:%S.%l} T:%t %-5p [%c] %m%n
#   #
#   # log4cpp.appender.device_debug=DailyRollingFileAppender
#   # log4cpp.appender.device_debug.fileName=/home/bit/.atol/drivers10/logs/device_debug.log
#   # log4cpp.appender.device_debug.maxDaysKeep=2
#   # log4cpp.appender.device_debug.layout=PatternLayout
#   # log4cpp.appender.device_debug.layout.ConversionPattern=%d{%Y.%m.%d %H:%M:%S.%l} T:%t %-5p [%c] %m%n
#   #
#   # log4cpp.appender.file1C=DailyRollingFileAppender
#   # log4cpp.appender.file1C.fileName=/home/bit/.atol/drivers10/logs/fptr1C.log
#   # log4cpp.appender.file1C.maxDaysKeep=2
#   # log4cpp.appender.file1C.layout=PatternLayout
#   # log4cpp.appender.file1C.layout.ConversionPattern=%d{%Y.%m.%d %H:%M:%S.%l} T:%t %-5p [%c] %m%n
#   #  ',
#   #   }
#
# }
