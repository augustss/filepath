{-# LANGUAGE CPP #-}
{-# LANGUAGE TemplateHaskellQuotes #-}
{-# LANGUAGE ViewPatterns #-}

#undef  POSIX
#define IS_WINDOWS True
#define WINDOWS
#define FILEPATH_NAME WindowsPath
#define OSSTRING_NAME WindowsString
#define WORD_NAME WindowsChar

#include "Common.hs"

#if defined(MIN_VERSION_template_haskell) || defined(MIN_VERSION_template_haskell_quasi_quoter)
-- | QuasiQuote a 'WindowsPath'. This accepts Unicode characters
-- and encodes as UTF-16LE. Runs 'isValid' on the input.
pstr :: QuasiQuoter
pstr =
  QuasiQuoter
  { quoteExp = \s -> do
      ps <- either (fail . show) pure $ encodeWith (mkUTF16le ErrorOnCodingFailure) s
      when (not $ isValid ps) $ fail ("filepath not valid: " ++ show ps)
      lift ps
  , quotePat = \s -> do
      osp' <- either (fail . show) pure . encodeWith (mkUTF16le ErrorOnCodingFailure) $ s
      when (not $ isValid osp') $ fail ("filepath not valid: " ++ show osp')
      [p|((==) osp' -> True)|]
  , quoteType = \_ ->
      fail "illegal QuasiQuote (allowed as expression or pattern only, used as a type)"
  , quoteDec  = \_ ->
      fail "illegal QuasiQuote (allowed as expression or pattern only, used as a declaration)"
  }
#else
pstr :: a
pstr = error "Systen.OsPath.Windows.pstr: no Template Haskell"
#endif /* defined(MIN_VERSION_template_haskell) || defined(MIN_VERSION_template_haskell_quasi_quoter) */
