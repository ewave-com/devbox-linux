<?php
/**
 * You can put here any PHP code should be executed before all pages are processes
 * Feel free to copy this file into your project configs dir and customize as you need, it will be prepared using DevBox config fallback
 * {project_folder}/configs/php/default/auto_prepend_file.php
 *
 * You can update some server variables or add custom code. for example in Magento it could be used to init custom stores
 *
 */

//function isHttpHost($host)
//{
//    if (!isset($_SERVER['HTTP_HOST'])) {
//        return false;
//    }
//    return strpos(str_replace('---', '.', $_SERVER['HTTP_HOST']), $host) === 0;
//}
//
//if (isHttpHost("mysite.local")) {
//    $_SERVER["MAGE_RUN_CODE"] = "mysite_default";
//    $_SERVER["MAGE_RUN_TYPE"] = "website";
//}
//
//if (isHttpHost("mysite2.local")) {
//    $_SERVER["MAGE_RUN_CODE"] = "mysite2_default";
//    $_SERVER["MAGE_RUN_TYPE"] = "website";
//}
