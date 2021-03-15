FC v2.5 comes with a plugin interface which allows adding you own preprocessing filters. Those filters will be 
available in the related dropdown list of the preprocessing panel in the UI. To add your own filters do the following:
 

1. Install a Java JDK (Java 8)
2. Make sure to add Plugin-1.0.jar to your build path if you're using Eclipse or a similar Java develeopment environment 
2. Create a new class "MyFilter" that implements IFilter ('public class MyFilter implements IFilter') 
3. Fill all the methods required by the IFilter interface 
3. Compile the 'MyFilter.java' file using 'javac.exe' and pack it into a .jar file  (check the javac documentation on how to do this)
4. Create a subfolder (e.g. "MyFilter") under \plugins\x86 or \plugins\x64 (depending if using 32bit or 64bit FC) 
4. Copy the *.jar file into your 'MyFilter' subfolder
5. After starting FC your "MyFilter" prefilter should be available in the pre-processing dropdown box


What's New in Plugin v1.1
======================================================================================================
- appendToLogfile(Properties) added to include key-value pairs to the capture logfile 
- useSlider() added to disable the slider in the pre-processing panel
- CamInfo.sensorTempInCelsius added
- activated() added which is called when the plugin is selected in the panel



