/*=====================================================================*/
/*    .../hop/linux/android/src/fr/inria/hop/HopInstaller.java         */
/*    -------------------------------------------------------------    */
/*    Author      :  Marcos Dione & Manuel Serrano                     */
/*    Creation    :  Fri Oct  1 08:46:18 2010                          */
/*    Last change :  Fri Oct  8 15:39:30 2010 (serrano)                */
/*    Copyright   :  2010 Marcos Dione & Manuel Serrano                */
/*    -------------------------------------------------------------    */
/*    Install Hop (from the zip file).                                 */
/*=====================================================================*/

/*---------------------------------------------------------------------*/
/*    The package                                                      */
/*---------------------------------------------------------------------*/
package fr.inria.hop;

import java.util.*;
import java.util.zip.*;
import java.io.*;

import android.app.Activity;
import android.util.Log;
import android.app.ProgressDialog;
import android.content.DialogInterface;

/*---------------------------------------------------------------------*/
/*    The class                                                        */
/*---------------------------------------------------------------------*/
public class HopInstaller extends Thread {
   // global constants
   final static String DOTAFILE = "dot.afile";
   final static String JSGZ = "jsgz";
   final static String ASSETS = "assets";
   final static int BUFSIZE = 10 * 1024;
   final static String USER = "hop";
   final static String PASSWORD = "hop";
   final static String CHMOD = "/system/bin/chmod 755";
   
   // instance variables
   Hop hop;
   ProgressDialog progress;

   String chmodbuf = "";
   int chmodbuflen = 0;

   // constructor
   public HopInstaller( Hop h, ProgressDialog p ) {
      super();

      hop = h;
      progress = p;
   }

   // static method
   public static boolean installed( Hop hop ) {
      return new File( hop.root + "/hoplib" ).exists();
   }
   
   // chmodflush
   private void chmodflush() throws IOException {
      if( chmodbuflen > 0 ) {
	 Runtime.getRuntime().exec( CHMOD + " " + chmodbuf );
	 chmodbuf = "";
	 chmodbuflen = 0;
      }
   }

   // dummy chmod
   private void chmod( String path ) throws IOException {
      chmodbuf += path + " ";

      if( chmodbuflen++ > 10 ) chmodflush();
   }
   
   // some filename have been mangled in the zip file
   private static String patchHopFilename( String path ) {
      if( path.endsWith( DOTAFILE ) ) {
	 return path.replace( DOTAFILE, ".afile" );
      } else if( path.endsWith( JSGZ ) ) {
	 return path.replace( JSGZ, "js.gz" );
      } else if( path.endsWith( "hoprc.hop" ) ) {
	 return path.replace( "config", ".config" );
      } else {
	 return path;
      }
   }

   // create a directory with the correct mod
   private void mkdir( File dir ) throws IOException {
      String pdir = dir.getAbsolutePath();
      
      dir.mkdirs();

      do {
	 chmod( pdir );
	 pdir = new File( pdir ).getParent();
      } while( !pdir.equals( hop.root ) );
   }

   // extract one stream from the zip archive
   public void copyStreams( InputStream is, FileOutputStream fos )
      throws IOException {
      BufferedOutputStream os = null;
      
      try {
         byte data[] = new byte[ BUFSIZE ];
         int count;
         os = new BufferedOutputStream( fos, BUFSIZE );
         while( (count = is.read( data, 0, BUFSIZE) ) != -1 ) {
	    os.write(data, 0, count);
         }
         os.flush();
      } finally {
	 if( os != null ) os.close();
      }
   }
   
   // filter out from the files list all those that are not under
   // the assets directory
   public Vector<ZipEntry> filesFromZip( ZipFile zip ) {
      Vector<ZipEntry> list = new Vector<ZipEntry>();
      Enumeration entries = zip.entries();
      while( entries.hasMoreElements() ) {
         ZipEntry entry = (ZipEntry)entries.nextElement();
         String name = entry.getName();
	 
         if( name.startsWith( ASSETS ) ) list.add(entry);
      }
      
      return list;
   }

   // unpacking the zip file
   public void unpack() throws IOException {
      File zipFile = new File( hop.apk );
      long zipLastModified = zipFile.lastModified();
      ZipFile zip = new ZipFile( hop.apk );
      Vector<ZipEntry> files = filesFromZip( zip );
      final Hashtable dirtable = new Hashtable();
      Enumeration entries = files.elements();
      int i = 0;

      progress.setMax( files.size() );
      
      while( entries.hasMoreElements() ) {
	 ZipEntry entry = (ZipEntry) entries.nextElement();
	 String path = entry.getName().substring( ASSETS.length() );

	 progress.setProgress( i++ );

	 // restore Hop file names
	 path = patchHopFilename( path );

	 // copy the new file
	 File outputFile = new File( hop.root, path );
	 File dir = outputFile.getParentFile();
	    
	 if( !dirtable.containsKey( dir ) ) {
	    dirtable.put( dir, new Boolean( true ) );
	    
	    Log.v( "HopInstaller", dir.getAbsolutePath() );
		  
	    if( !dir.isDirectory() ) {
	       mkdir( dir );
	    }
	 }

	 if( outputFile.exists()
	     && (entry.getSize() == outputFile.length())
	     && (zipLastModified < outputFile.lastModified()) ) {
	    ;
	 } else {
	    FileOutputStream fos = new FileOutputStream( outputFile );

	    copyStreams( zip.getInputStream( entry ), fos );
	    String curPath = outputFile.getAbsolutePath();
	    chmod( curPath );
	 }
      }

      // we have to execute the chmod mode now
      chmodflush();
   }

   public void run() {
      try {
	 Log.i( "HopInstaller", "unpacking" );
	 unpack();
      } catch( Exception e ) {
	 String msg = e.getMessage();
	 if( msg == null ) msg = e.getClass().getName();
	 
	 Log.e( "HopInstaller", msg );
	 hop.handler.sendMessage( android.os.Message.obtain( hop.handler, HopLauncher.MSG_INSTALL_FAIL, e ) );
      }
   }
}